Shader "Custom/Particles/Alpha Blend Masked Tint Emissive"
{
	Properties
	{
		_TintColor ("Tint Color (RGB)  Trans (A)" , Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture - Tinted Alpha (R) Glow (G)", 2D) = "white" {}
		_MainEdge ("Main Alpha Erosion", Range(0.00,1.00)) = 0
		_GlowColor1 ("Glow White Point" , Color) = (1,1,1,0)
		_GlowColor2 ("Glow Black Point" , Color) = (0,0,0,0)
		_GlowEdge ("Glow Erosion", Range(0.00,1.00)) = 0
		_MaskTex ("Mask Texture (R)", 2D) = "white" {}
		_MaskEdge ("Mask Texture Erosion", Range(0.00,1.00)) = 0
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

				half4 _TintColor, _MainTex_ST, _GlowColor1, _GlowColor2, _MaskTex_ST;
				sampler2D _MainTex, _MaskTex;
				half _MainEdge, _GlowEdge, _MaskEdge;

				struct appdata
				{
				    float4 vertex : POSITION;
				    half4 texcoord0 : TEXCOORD0;
				    half texcoord1 : TEXCOORD1;
				    half4 color : COLOR;
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					half2 uv0 : TEXCOORD0;
					half3 custom : TEXCOORD1;
					half2 uv1 : TEXCOORD2;
					half4 color : COLOR;
				};


				v2f vert (appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.color = v.color;
					o.uv0 = TRANSFORM_TEX(v.texcoord0,_MainTex);
					o.uv1 = TRANSFORM_TEX(v.texcoord0,_MaskTex);
					o.custom = half3(v.texcoord0.zw,v.texcoord1);
					return o;
				}
				
				half4 frag (v2f i) : SV_Target
				{
					half4 tex = tex2D(_MainTex, i.uv0);
					//Base
					half baseA = erode(tex.r, _MainEdge + i.custom.x);
					//Glow
					half glowA = erode(tex.g, _GlowEdge + i.custom.y);
					half4 glow = lerp(_GlowColor2, _GlowColor1, glowA);
					half3 col = lerp(_TintColor, glow.rgb, glowA * glow.a);
					//Alpha
					half mask = erode(tex2D(_MaskTex, i.uv1).x, _MaskEdge + i.custom.z);
					mask *= baseA * _TintColor.a;
					//return baseA.xxxx;
					return half4(col.rgb,mask) * i.color;
				}
				ENDCG 
			}
		}	
	}
}
