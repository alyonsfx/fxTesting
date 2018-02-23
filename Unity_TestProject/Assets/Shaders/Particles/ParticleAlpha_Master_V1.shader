Shader "Custom/Particles/Master Shader v1"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		[NoScaleOffset] _MainTex ("Particle Texture - Main (R) Glow (G) Mask (B)", 2D) = "black" {}
		_Main_UV ("Main Texture Tiling (XY) Offset (ZW)", Vector) = (1,1,0,0)
		_MainA ("Main Texture Alpha Erosion", Range(0.00,1.00)) = 0.1
		_GlowColor ("Glow Color", Color) = (1,1,1,1)
		_GlowA ("Glow Texture Alpha Erosion", Range(0.00,1.00)) = 0.1
		_Mask_UV ("Mask Texture Tiling (XY) Offset (ZW)", Vector) = (1,1,0,0)
		_MaskA ("Mask Texture Alpha Erosion", Range(0.00,1.00)) = 0.1
		_HueShift ("Hue Shift", Range(0.00,1.00)) = 0
		[NoScaleOffset] _RampTex("Color Remap Texture", 2D) = "black" { }
		_Scroll ("Scroll Speed - Main (XY) Mask (ZW)", Vector) = (0,0,0,0)
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

				half4 _TintColor, _Main_UV, _GlowColor, _Mask_UV, _Scroll;
				sampler2D _MainTex, _MaskTex, _RampTex;
				half _MainA, _GlowA, _MaskA, _HueShift;

				struct appdata
				{
				    half4 vertex : POSITION;
				    half4 texcoord0 : TEXCOORD0;
				    half4 color : COLOR;
				};

				struct v2f
				{
					half4 pos : SV_POSITION;
					half2 uv0 : TEXCOORD0;
					half2 uv1 : TEXCOORD1;
					half4 color : COLOR;
				};

				v2f vert (appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.color = v.color * _TintColor * 2;
					o.uv0 = setupUVs(v.texcoord0, _Main_UV, _Scroll.xy);
					o.uv1 = setupUVs(v.texcoord0, _Mask_UV, _Scroll.zw);
					return o;
				}
				
				half4 frag (v2f i) : SV_Target
				{
					half2 tex = tex2D(_MainTex, i.uv0).xy;
					tex.x = erode(tex.x, _MainA);
					half3 col = tex2D(_RampTex, half2(tex.x,0));
					hueShift(col, _HueShift);
					col *= i.color.xyz;
					tex.y = erode(tex.y, _GlowA);
					col = lerp(col, _GlowColor.xyz, _GlowColor.w * tex.y);


					half mask = erode(tex2D(_MainTex, i.uv1).z,_MaskA);






					return half4(col.xyz,tex.x * mask * i.color.w);


//					col.a = tex;
//					col *= i.color;
//					col.a = erode(col.a, _MainA);
//					hueShift(col, _HueShift);
//					col.a *= erode(tex2D(_MaskTex, i.uv1).x, _MaskA);
					//return col;
				}
				ENDCG 
			}
		}	
	}
}
