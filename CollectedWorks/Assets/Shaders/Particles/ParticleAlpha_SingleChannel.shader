// Based on Mobile/Particles/Alpha Blended
// Uses the red channel as an alpha
// Tint color is doubled

Shader "Custom/Particles/Alpha Blended (Single Channel)"
{
    Properties
    {
        _TintColor ("Tint Color", Color) = (0.5, 0.5, 0.5, 0.5)
        _MainTex ("Particle Mask (R)", 2D) = "white" { }
    }

    Category
    {
        SubShader
        {
            Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" }

            Pass
            {
                Blend SrcAlpha OneMinusSrcAlpha
                Cull Off
                ZWrite Off
                
                CGPROGRAM
                
                #pragma vertex vert
                #pragma fragment frag
                #pragma fragmentoption ARB_precision_hint_fastest
                #pragma target 2.0

                #include "UnityCG.cginc"

                half4 _TintColor, _MainTex_ST;
                sampler2D _MainTex;
                
                struct appdata
                {
                    float4 vertex: POSITION;
                    half2 texcoord: TEXCOORD0;
                    half4 color: COLOR;
                };

                struct v2f
                {
                    float4 pos: SV_POSITION;
                    half2 uv: TEXCOORD0;
                    half4 color: COLOR;
                };

                v2f vert(appdata v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.color = v.color * _TintColor * 2;
                    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                    return o;
                }
                
                half4 frag(v2f i): SV_Target
                {
                    half4 col = i.color;
                    col.a *= tex2D(_MainTex, i.uv).r;
                    return col;
                }
                ENDCG
                
            }
        }
    }
}