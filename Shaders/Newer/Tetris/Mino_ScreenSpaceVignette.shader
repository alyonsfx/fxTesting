Shader "Custom/Mino/Sprite Vignette"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
        _Intensity ("Intensity", Float) = 1
        _Falloff ("Falloff", Float) = 1
        _Roundness ("Roundness", Float) = 1
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1, 1, 1, 1)
        [HideInInspector] _Flip ("Flip", Vector) = (1, 1, 1, 1)
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

            sampler2D _MainTex;
            half _Intensity, _Falloff, _Roundness;

            struct appdata_t
            {
                half4 vertex: POSITION;
                half4 color: COLOR;
            };

            struct v2f
            {
                half4 vertex: SV_POSITION;
                half4 color: COLOR;
                half4 texcoord0: TEXCOORD0;
            };

            v2f SpriteVert(appdata_t IN)
            {
                v2f OUT;

                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.color = IN.color;
                OUT.texcoord0 = ComputeScreenPos(OUT.vertex);

                return OUT;
            }

            half4 SpriteFrag(v2f IN): SV_Target
            {
                half4 col = IN.color;
                half2 screenPos = IN.texcoord0.xy / IN.texcoord0.w;

                half2 d = abs(screenPos - half2(0.5, 0.5)) * _Intensity;
                d.x *= (_ScreenParams.x / _ScreenParams.y);
                d = pow(saturate(d), _Roundness);
                d = saturate(1.0 - dot(d, d));
                d = saturate(pow(d, _Falloff));
                d = 1 - d;
                col.a *= d;

                return col;
            }
            ENDCG

        }
    }
}
