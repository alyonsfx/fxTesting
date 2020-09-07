Shader "Test/Normal Facing Color"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_Darken ("Backface Shading", Range(0.00,1.00)) = 0.25
		_MainTex ("Particle Mask (R)", 2D) = "white" {}
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
				//ZWrite On

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma target 2.0

				#include "UnityCG.cginc"

				half4 _TintColor, _MainTex_ST;
				sampler2D _MainTex;
				half _Darken;
				
				struct appdata_vuc
				{
				    half4 vertex : POSITION;
				    half4 texcoord : TEXCOORD0;
				    half4 color : COLOR;
				    half3 normal : NORMAL;
				};

				struct v2f_vuc
				{
					half4 pos : SV_POSITION;
					half2 uv : TEXCOORD0;
					half4 color : COLOR;
					half custom : TEXCOORD1;
				};

				v2f_vuc vert (appdata_vuc v)
				{
					v2f_vuc o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.color = v.color * _TintColor * 2;
					o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
					half3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
					o.custom = dot(viewDir, v.normal);
					return o;
				}
				
				half4 frag (v2f_vuc i) : SV_Target
				{
					half4 col = i.color;
					col.xyz *= lerp(1- _Darken, 1, step(0, i.custom));
					col.a = tex2D(_MainTex, i.uv).r;
					return col;
				}
				ENDCG 
			}
		}	
	}
}