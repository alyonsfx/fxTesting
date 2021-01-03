Shader "Custom/Mino/Masked Screenspace Angle Gardient"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
        _LUT ("Look Up Table", 2D) = "white" { }
        _Speed ("Color Speed", Float) = 1
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1, 1, 1, 1)
        [HideInInspector] _Flip ("Flip", Vector) = (1, 1, 1, 1)
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "True" }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend SrcAlpha One

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

            #endif

            // instancing
            CBUFFER_START(UnityPerDrawSprite)
            #ifndef UNITY_INSTANCING_ENABLED
                half4 _RendererColor;
                half2 _Flip;
            #endif
            CBUFFER_END

            // Material Color.
            sampler2D _MainTex, _LUT;
            half _Speed;

            inline half4 UnityFlipSprite(in half3 pos, in half2 flip)
            {
                return half4(pos.xy * flip, pos.z, 1.0);
            }

            struct appdata_t
            {
                half4 vertex: POSITION;
                half4 color: COLOR;
                half2 texcoord: TEXCOORD0;
            };

            struct v2f
            {
                half4 vertex: SV_POSITION;
                half4 color: COLOR;
                half2 texcoord0: TEXCOORD0;
                half4 texcoord1: TEXCOORD1;
            };

            v2f SpriteVert(appdata_t IN)
            {
                v2f OUT;

                OUT.vertex = UnityFlipSprite(IN.vertex, _Flip);
                OUT.vertex = UnityObjectToClipPos(OUT.vertex);
                OUT.color = IN.color;
                OUT.texcoord1 = ComputeScreenPos(OUT.vertex);

                OUT.texcoord0 = IN.texcoord;

                #ifdef PIXELSNAP_ON
                    OUT.vertex = UnityPixelSnap(OUT.vertex);
                #endif

                return OUT;
            }

            half4 SpriteFrag(v2f IN): SV_Target
            {
                // Sprite texture
                half sprite = tex2D(_MainTex, IN.texcoord0).r;
                half2 colorUVs = IN.texcoord1.xy / IN.texcoord1.w;
                colorUVs = remap(colorUVs, half2(0, 1), half2(-1, 1));
                half mask = atan2(colorUVs.y, colorUVs.x);
                mask = remap(mask, half2(-3.14, 3.14), half2(0, 1)) * 2;
                mask += _Time.y * _Speed;
                half3 col = tex2D(_LUT, half2(frac(mask), 0.5)) * sprite;
                return half4(col, 1) * IN.color;
            }
            
            ENDCG
            
        }
    }
}
