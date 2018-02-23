Shader "Custom/Particles/Alpha Blended (Solid Color)"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Mask (R)", 2D) = "white" {}
        _Erode ("Alpha Erossion", Range(0.00,1.00)) = 0
	}

	Category
	{
		SubShader
		{
			Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }

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
                #include "../Family.cginc"

				half4 _TintColor, _MainTex_ST;
				sampler2D _MainTex;
                half _Erode;
				
                struct appdata
                {
                    float4 vertex : POSITION;
                    half4 texcoord0 : TEXCOORD0;
                    half4 color : COLOR;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    half3 uv : TEXCOORD0;
                    half4 color : COLOR;
                };

                v2f vert (appdata v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.color = v.color * _TintColor * 2;
                    o.uv.xy = TRANSFORM_TEX(v.texcoord0.xy,_MainTex);
                    o.uv.z = (1-_Erode) * (1-v.texcoord0.z);
                    return o;
                }
				
				half4 frag (v2f i) : SV_Target
				{
					half4 col = i.color;
					col.a *= erode(tex2D(_MainTex, i.uv).r, i.uv.z);
					return col;
				}
				ENDCG 
			}
		}	
	}
}