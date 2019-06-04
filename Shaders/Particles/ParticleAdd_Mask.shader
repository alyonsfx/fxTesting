Shader "Custom/Particles/Additive (Masked)"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_MaskTex ("Mask Texture (Greyscale))", 2D) = "white" {}
		_Scroll ("Scroll Speed - Main (XY) Mask (ZW)", Vector) = (0,0,0,0)
	}

	Category
	{
		SubShader
		{
			Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }

			Pass
			{
				Blend SrcAlpha One
				Cull Off
				ZWrite Off

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma target 2.0

				#include "UnityCG.cginc"
				#include "../Family.cginc"

				half4 _TintColor, _MainTex_ST, _MaskTex_ST, _Scroll;
				sampler2D _MainTex, _MaskTex;

				struct appdata
				{
				    float4 vertex : POSITION;
				    half2 texcoord0 : TEXCOORD0;
				    half4 color : COLOR;
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					half2 uv0 : TEXCOORD0;
					half2 uv1 : TEXCOORD1;
					half4 color : COLOR;
				};

				v2f vert (appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.color = v.color * _TintColor * 2;
					o.uv0 = TRANSFORM_TEX(v.texcoord0,_MainTex);
					o.uv0 = scrollUVs(o.uv0, _Scroll.xy);
					o.uv1 = TRANSFORM_TEX(v.texcoord0,_MaskTex);
					o.uv1 = scrollUVs(o.uv1, _Scroll.zw);
					return o;
				}
				
				half4 frag (v2f i) : SV_Target
				{
					half4 col = i.color * tex2D(_MainTex, i.uv0);
					col *= tex2D(_MaskTex, i.uv1).xxxx;
					return col;
				}
				ENDCG 
			}
		}	
	}
}
