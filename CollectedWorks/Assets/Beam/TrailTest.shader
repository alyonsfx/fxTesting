// Based on Mobile/Particles/Alpha Blended
// Adds tint color and double value

Shader "Custom/Particles/Alpha Blended"
{
    Properties
    {
        _TintColor ("Tint Color", Color) = (1, 1, 1, 1)
        _MainTex ("Main (R) Distortion XY (GB) Mask (A)", 2D) = "white" { }
		_LUT ("Color Lookup Texture", 2D) = "white" { }
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

CBUFFER_START(UnityPerMaterial)
 
                half4 _TintColor, _MainTex_ST;
                sampler2D _MainTex, _LUT;
 
CBUFFER_END
                
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
                    o.color = v.color;
                    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                    return o;
                }
                
                half4 frag(v2f i): SV_Target
                {
                    half3 mainTex = tex2D(_MainTex, i.uv).xyz;
					half2 distortedUVs = mainTex.yz * 0.2;
					distortedUVs -= 0.1;
					half mask = tex2D(_MainTex, distortedUVs* _SinTime.w).a;
					//mask = frac(mask+_SinTime);
					mask = step(i.color.r,mask);
					half main = mainTex.x*mask;
					main = lerp(main,main*mask,i.color.g);
					half3 col= tex2D(_LUT,half2(main,0.5));
					return half4(col,main);
                }
                ENDCG
                
            }
        }
    }
}