Shader "Mobile/Particles/Additive (Cull Back)"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
	}

	Category
	{
		SubShader
		{
			Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }

			Pass
			{
				Blend SrcAlpha One
				ZWrite Off

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma target 2.0

				#include "UnityCG.cginc"

				half4 _TintColor, _MainTex_ST;
				sampler2D _MainTex;
				
				struct appdata_vuc
				{
				    float4 vertex : POSITION;
				    half4 texcoord : TEXCOORD0;
				    half4 color : COLOR;
				};

				struct v2f_vuc
				{
					float4 pos : SV_POSITION;
					half2 uv : TEXCOORD0;
					half4 color : COLOR;
				};

				v2f_vuc vert (appdata_vuc v)
				{
					v2f_vuc o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.color = v.color * _TintColor * 2;
					o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
					return o;
				}
				
				half4 frag (v2f_vuc i) : SV_Target
				{
					return i.color * tex2D(_MainTex, i.uv);
				}
				ENDCG
			}
		}	
	}
}