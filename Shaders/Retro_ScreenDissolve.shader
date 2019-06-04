Shader "Mino/Retro/Screen Dissolve"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
        _Erode ("Errosion", Float) = 0
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1, 1, 1, 1)
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
    }


    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "True" }

        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        Lighting Off
        ZWrite Off

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

            #endif

            // instancing
            CBUFFER_START(UnityPerDrawSprite)
            #ifndef UNITY_INSTANCING_ENABLED
                half4 _RendererColor;
            #endif
            CBUFFER_END

            half _Erode;
            half4 _TintColor;
            sampler2D _MainTex;

            struct appdata_t
            {
                half4 vertex: POSITION;
                half4 color: COLOR;
                half2 texcoord: TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex: SV_POSITION;
                half2 texcoord0: TEXCOORD0;
                half4 texcoord1: TEXCOORD1;
                half4 color: COLOR;
            };

            v2f SpriteVert(appdata_t IN)
            {
                v2f OUT;

                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.color = IN.color;

                // Main sprite UVs
                OUT.texcoord0 = IN.texcoord;
                // Screenspace info for the pulse and scanlines
                OUT.texcoord1 = ComputeScreenPos(OUT.vertex);

                #ifdef PIXELSNAP_ON
                    OUT.vertex = UnityPixelSnap(OUT.vertex);
                #endif

                return OUT;
            }

            
            half4 SpriteFrag(v2f IN): SV_Target
            {
                half2 screenPos = IN.texcoord1.xy / IN.texcoord1.w;
                half dist = distance(screenPos, half2(0.5, 0.5));
                half fade = erode(1 - dist, 1 - _Erode);

                half tex = tex2D(_MainTex, IN.texcoord0).r;
                half4 col = IN.color;
                col.a *= step(fade, tex);
                col.rgb *= col.a;
                return col;
            }
            ENDCG
            
        }
    }
}