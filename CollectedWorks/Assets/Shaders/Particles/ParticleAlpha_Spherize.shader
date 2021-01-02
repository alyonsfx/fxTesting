Shader "Custom/Particles/Custom Data/Alpha Blended (Spherize Masked)"
{
    Properties
    {
        _TintColor ("Tint Color", Color) = (0.5, 0.5, 0.5, 0.5)
        _MainTex ("Particle Texture", 2D) = "white" { }
        _MaskTex ("Mask Texture (R)", 2D) = "white" { }
    }

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
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "../N3twork.cginc"

            half4 _TintColor, _MainTex_ST, _MaskTex_ST;
            sampler2D _MainTex, _MaskTex;
            
            struct appdata
            {
                half4 vertex: POSITION;
                float4 texcoord0: TEXCOORD0;
                half4 color: COLOR;
            };

            struct v2f
            {
                half4 pos: SV_POSITION;
                float2 uv0: TEXCOORD0;
                half2 uv1: TEXCOORD1;
                half4 color: COLOR;
                half2 custom: TEXCOORD2;
            };
            
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.color * _TintColor * 2;
                o.uv0 = TRANSFORM_TEX(v.texcoord0, _MainTex);
                o.uv1 = TRANSFORM_TEX(v.texcoord0, _MaskTex);
                o.custom = v.texcoord0.zw;
                return o;
            }

            float sphere(float t, float k)
            {
                float d = 1.0 + t * t - t * t * k * k;
                if (d <= 0.0)
                    return - 1.0;
                float x = (k - sqrt(d)) / (1.0 + t * t);
                return asin(x * t);
            }

            float2 warpUVs(float2 uv, half k)
            {
                uv -= 0.5;
                uv *= 2.0;
                float t = length(uv);
                float len2 = sphere(t * k, sqrt(2.0)) / sphere(1.0 * k, sqrt(2.0));
                uv = uv * len2 * 0.5 / t;
                uv = uv + 0.5;
                return uv;
            }
            
            half4 frag(v2f i): SV_Target
            {
                half4 col = tex2D(_MainTex, warpUVs(i.uv0, i.custom.x)) * i.color;
                half mask = step(i.custom.y, tex2D(_MaskTex, i.uv1).r);
                col.a *= mask;
                return col;
            }
            
            ENDCG
            
        }
    }
}
