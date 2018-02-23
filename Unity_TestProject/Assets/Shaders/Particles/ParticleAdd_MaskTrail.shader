Shader "Custom/Particles/Additive Trail"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_MaskTex ("Mask Texture (Greyscale))", 2D) = "white" {}
		_Scroll ("Scroll Speed - Main (XY) Mask (ZW)", Vector) = (0,0,0,0)
		_Fade ("Fade Edge", Float) = 0.75
		[NoScaleOffset] _RampTex("Color Remap Texture", 2D) = "black" { }
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
				sampler2D _MainTex, _MaskTex, _RampTex;
				half _Fade;

                struct appdata
                {
                    float4 vertex : POSITION;
                    half4 texcoord0 : TEXCOORD0;
                    half4 color : COLOR;
                };

                struct v2f
                {
                    float pos : SV_POSITION;
                    half4 color : COLOR;
                    half4 uv0 : TEXCOORD0;
                    half uv1 : TEXCOORD1;
                };

				v2f vert (appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.color = v.color * _TintColor * 2;
                    o.uv1 = v.texcoord0.x;
					o.uv0.xy = TRANSFORM_TEX(v.texcoord0,_MainTex);
					o.uv0.xy = scrollUVs(o.uv0.xy, _Scroll.xy);
					o.uv0.zw = TRANSFORM_TEX(v.texcoord0,_MaskTex);
					o.uv0.zw = scrollUVs(o.uv0.zw, _Scroll.zw);
					return o;
				}
				
				half4 frag (v2f i) : SV_Target
				{
					half tex = tex2D(_MainTex, i.uv0.xy);
                    tex = erode(tex, (1-i.uv1) *_Fade);
                    tex *= tex2D(_MaskTex, i.uv0.zw).x;
                    half4 col = tex2D(_RampTex, half2(tex,0)) * i.color;
                    col *= tex;
                    return col;
				}
				ENDCG 
			}
		}	
	}
}
