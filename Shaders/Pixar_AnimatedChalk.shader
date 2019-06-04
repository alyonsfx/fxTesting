Shader "Mino/Pixar/Animated Chalk"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
        _ColumnsX ("Columns (X)", int) = 1
        _RowsY ("Rows (Y)", int) = 1
        _AnimSpeed ("Frames Per Seconds", float) = 10
        _AnimOffset ("Animation Offset", float) = 0
        _AtlasInfo ("Description", Vector) = (1, 1, 1, 1)
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
            #include "N3twork.cginc"

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
            half _AnimSpeed, _AnimOffset;
            half4 _AtlasInfo;
            uniform half4 _MainTex_TexelSize;

            inline half4 UnityFlipSprite(in half3 pos, in half2 flip)
            {
                return half4(pos.xy * flip, pos.z, 1.0);
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
                uvs.x *= _MainTex_TexelSize.z;
                uvs.x -= _AtlasInfo.x;
                uvs.x /= _AtlasInfo.z;
                uvs.y *= _MainTex_TexelSize.w;
                uvs.y -= _AtlasInfo.y;
                uvs.y /= _AtlasInfo.w;

                // Do flipbook calculations
                uvs = flipbookUVs(uvs, half2(_ColumnsX, _RowsY), _AnimSpeed, _AnimOffset);
                
                // Convert UV cordinates back relative to the entire atlas
                uvs.x *= _AtlasInfo.z;
                uvs.x += _AtlasInfo.x;
                uvs.x *= _MainTex_TexelSize.x;
                uvs.y *= _AtlasInfo.w;
                uvs.y += _AtlasInfo.y;
                uvs.y *= _MainTex_TexelSize.y;

                OUT.texcoord = uvs;
                OUT.color = IN.color;

                #ifdef PIXELSNAP_ON
                    OUT.vertex = UnityPixelSnap(OUT.vertex);
                #endif

                return OUT;
            }


            half4 SpriteFrag(v2f IN): SV_Target
            {
                half tex = erode(tex2D(_MainTex, IN.texcoord).a, 1 - IN.color.a);
                half4 col = IN.color;
                col.a = tex;
                col.rgb *= col.a;
                return col;
            }
            
            ENDCG
            
        }
    }
}
