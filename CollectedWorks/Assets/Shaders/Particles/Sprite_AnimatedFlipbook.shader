Shader "Sprites/Custom/Animated Flipbook"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
        _ColumnsX ("Columns (X)", int) = 1
        _RowsY ("Rows (Y)", int) = 1
        _AnimSpeed ("Frames Per Seconds", float) = 10
        _AtlasInfo ("X Position, Y Position, Width, Height", Vector) = (1, 1, 1, 1)
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1, 1, 1, 1)
        [HideInInspector] _Flip ("Flip", Vector) = (1, 1, 1, 1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" { }
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "True" }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            
            #pragma vertex SpriteVert
            #pragma fragment SpriteFrag
            #pragma target 2.0
            #pragma multi_compile_instancing
            #pragma multi_compile _ PIXELSNAP_ON
            #include "UnityCG.cginc"

            #ifdef UNITY_INSTANCING_ENABLED

                UNITY_INSTANCING_BUFFER_START(PerDrawSprite)
                // SpriteRenderer.Color while Non-Batched/Instanced.
                UNITY_DEFINE_INSTANCED_PROP(fixed4, unity_SpriteRendererColorArray)
                // this could be smaller but that's how bit each entry is regardless of type
                UNITY_DEFINE_INSTANCED_PROP(fixed2, unity_SpriteFlipArray)
                UNITY_INSTANCING_BUFFER_END(PerDrawSprite)

                #define _RendererColor  UNITY_ACCESS_INSTANCED_PROP(PerDrawSprite, unity_SpriteRendererColorArray)
                #define _Flip           UNITY_ACCESS_INSTANCED_PROP(PerDrawSprite, unity_SpriteFlipArray)

            #endif // instancing

            CBUFFER_START(UnityPerDrawSprite)
            #ifndef UNITY_INSTANCING_ENABLED
                half4 _RendererColor;
                half2 _Flip;
            #endif
            CBUFFER_END

            // Material Color.
            sampler2D _MainTex;
            uint _ColumnsX;
            uint _RowsY;
            half _AnimSpeed;
            half4 _AtlasInfo;
            uniform half4 _MainTex_TexelSize;

            inline half4 UnityFlipSprite(in half3 pos, in half2 flip)
            {
                return half4(pos.xy * flip, pos.z, 1.0);
            }

            half2 flipbookUVs(half2 IN, half2 layout, half speed)
            {
                // get single sprite size
                float2 size = float2(1.0f / layout.x, 1.0f / layout.y);
                uint totalFrames = layout.x * layout.y;
                // use timer to increment index
                uint index = _Time.y * speed;
                // wrap x and y indexes
                uint indexX = index % layout.x;
                uint indexY = floor((index % totalFrames) / layout.x);
                // get offsets to our sprite index
                float2 frameOffset = float2(size.x * indexX, -size.y * indexY);
                // get single sprite UV
                float2 newUV = IN * size;
                // flip Y (to start 0 from top)
                newUV.y = newUV.y + size.y * (layout.y - 1);
                return newUV + frameOffset;
            }

            struct appdata
            {
                half4 vertex: POSITION;
                half4 color: COLOR;
                half2 texcoord: TEXCOORD0;
            };

            struct v2f
            {
                half4 vertex: SV_POSITION;
                half4 color: COLOR;
                half2 texcoord: TEXCOORD0;
            };

            v2f SpriteVert(appdata IN)
            {
                v2f OUT;

                OUT.vertex = UnityFlipSprite(IN.vertex, _Flip);
                OUT.vertex = UnityObjectToClipPos(OUT.vertex);

                half2 uvs = IN.texcoord;

                // Convert UV cordinates so they are local to sprite
                uvs.x = (uvs.x * _MainTex_TexelSize.z - _AtlasInfo.x) / _AtlasInfo.z;
                uvs.y = (uvs.y * _MainTex_TexelSize.w - _AtlasInfo.y) / _AtlasInfo.w;

                // Do flipbook calculations
                uvs = flipbookUVs(uvs, half2(_ColumnsX, _RowsY), _AnimSpeed);
                
                // Convert UV cordinates back relative to the entire atlas
                uvs.x = (uvs.x * _AtlasInfo.z + _AtlasInfo.x) * _MainTex_TexelSize.x;
                uvs.y = (uvs.y * _AtlasInfo.w + _AtlasInfo.y) * _MainTex_TexelSize.y;

                OUT.texcoord = uvs;
                OUT.color = IN.color;

                #ifdef PIXELSNAP_ON
                    OUT.vertex = UnityPixelSnap(OUT.vertex);
                #endif

                return OUT;
            }

            half4 SpriteFrag(v2f IN): SV_Target
            {
                half4 c = tex2D(_MainTex, IN.texcoord) * IN.color;
                c.rgb *= c.a;
                return c;
            }
            ENDCG
            
        }
    }
}
