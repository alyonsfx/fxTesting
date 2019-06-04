// Red channel the vertex color
// Blue channel main color "_Color"

Shader "Mino/Tron Board Sprites"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
        _Color ("Tint", Color) = (1, 1, 1, 1)
        [NoScaleOffset] _ScanlineTex ("Scanline Texture", 2D) = "white" { }
        _ScanlineScale ("Scanline Scale", Float) = 40
        _ScanlineSpeed ("Scanline Speed", Float) = -0.5
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
        Blend SrcAlpha One

        Pass
        {
            CGPROGRAM
            
            #pragma vertex SpriteVert
            #pragma fragment SpriteFrag
            #pragma target 2.0
            #pragma multi_compile_instancing
            #pragma multi_compile _ PIXELSNAP_ON
            #pragma multi_compile _ ETC1_EXTERNAL_ALPHA
            #include "UnityCG.cginc"

            #ifdef UNITY_INSTANCING_ENABLED

                UNITY_INSTANCING_BUFFER_START(PerDrawSprite)
                // SpriteRenderer.Color while Non-Batched/Instanced.
                UNITY_DEFINE_INSTANCED_PROP(fixed4, unity_SpriteRendererColorArray)
                // this could be smaller but that's how bit each entry is regardless of type
                UNITY_DEFINE_INSTANCED_PROP(fixed2, unity_SpriteFlipArray)
                UNITY_INSTANCING_BUFFER_END(PerDrawSprite)

                #define _Flip           UNITY_ACCESS_INSTANCED_PROP(PerDrawSprite, unity_SpriteFlipArray)

            #endif // instancing

            CBUFFER_START(UnityPerDrawSprite)
            #ifndef UNITY_INSTANCING_ENABLED
                half2 _Flip;
            #endif
            float _EnableExternalAlpha;
            CBUFFER_END

            // Material Color.
            half4 _Color;
            sampler2D _MainTex, _AlphaTex, _ScanlineTex;
            half _ScanlineScale, _ScanlineSpeed;

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
                half2 texcoord: TEXCOORD0;
                half4 texcoord1: TEXCOORD1;
            };

            v2f SpriteVert(appdata_t IN)
            {
                v2f OUT;

                OUT.vertex = UnityFlipSprite(IN.vertex, _Flip);
                OUT.vertex = UnityObjectToClipPos(OUT.vertex);
                OUT.texcoord = IN.texcoord;
                OUT.texcoord1 = ComputeScreenPos(OUT.vertex);
                OUT.color = IN.color;

                #ifdef PIXELSNAP_ON
                    OUT.vertex = UnityPixelSnap(OUT.vertex);
                #endif

                return OUT;
            }

            half4 SampleSpriteTexture(half2 uv)
            {
                half4 color = tex2D(_MainTex, uv);

                #if ETC1_EXTERNAL_ALPHA
                    half4 alpha = tex2D(_AlphaTex, uv);
                    color.a = lerp(color.a, alpha.r, _EnableExternalAlpha);
                #endif

                return color;
            }

            half4 SpriteFrag(v2f IN): SV_Target
            {
                half y = frac(IN.texcoord1.y * _ScanlineScale + _Time.x * _ScanlineSpeed);
                half scan = tex2D(_ScanlineTex, half2(0, y));

                half2 tex = SampleSpriteTexture(IN.texcoord).rb;
                half4 col = lerp(IN.color, _Color, tex.y * _Color.a);
                col.a = tex.x * IN.color.a;
                col.rgb *= col.a * scan;
                return col;
            }
            
            ENDCG
            
        }
    }
}