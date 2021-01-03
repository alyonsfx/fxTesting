Shader "Mobile/Particles/Additive (Overlay)"
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
			Tags { "Queue"="Overlay" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }

			Pass
			{
				Blend SrcAlpha One
				ZWrite Off
                Cull Off

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma target 2.0

				#include "UnityCG.cginc"

				half4 _TintColor;
				sampler2D _MainTex;
				half4 _MainTex_ST;
				
				struct appdata_t
				{
					float4 vertex : POSITION;
					half4 color : COLOR;
					half2 texcoord : TEXCOORD0;
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					half4 color : COLOR;
					half2 uv : TEXCOORD0;
				};

				v2f vert (appdata_t v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.color = v.color * _TintColor * 2;
					o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
					return o;
				}
				
				half4 frag (v2f i) : SV_Target
				{
					return i.color * tex2D(_MainTex, i.uv);
				}
				ENDCG 
			}
		}	
	}
}