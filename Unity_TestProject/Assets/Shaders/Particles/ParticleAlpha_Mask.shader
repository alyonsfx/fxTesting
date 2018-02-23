Shader "Custom/Particles/Alpha Blended (Masked)"
{
	Properties
	{
		_TintColor ("Tint Color (RGB)  Trans (A)" , Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
        _MainErode ("Main Alpha Erossion", Range(0.00,1.00)) = 0
		_MaskTex ("Mask Texture (R)", 2D) = "white" {}
        _MaskErode ("Mask Alpha Erossion", Range(0.00,1.00)) = 0
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

				half4 _TintColor, _MainTex_ST, _MaskTex_ST, _Scroll;
				sampler2D _MainTex, _MaskTex; 
                half _MainErode, _MaskErode;

                struct appdata
                {
                    float4 vertex : POSITION;
                    half4 texcoord0 : TEXCOORD0;
                    half4 color : COLOR;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    half4 uv0 : TEXCOORD0;
                    half2 uv1 : TEXCOORD1;
                    half4 color : COLOR;
                };

				v2f vert (appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.color = v.color * _TintColor * 2;
					o.uv0.xy = TRANSFORM_TEX(v.texcoord0,_MainTex);
					o.uv0.xy = scrollUVs(o.uv0.yx, _Scroll.xy);
					o.uv1 = TRANSFORM_TEX(v.texcoord0,_MaskTex);
					o.uv1 = scrollUVs(o.uv1, _Scroll.zw);
                    o.uv0.z = (1-_MainErode) * (1-v.texcoord0.z);
                    o.uv0.w = (1-_MaskErode) * (1-v.texcoord0.w);
					return o;
				}
				
				half4 frag (v2f i) : SV_Target
				{
					half4 col = tex2D(_MainTex, i.uv0);
                    col.a = erode(col.a, i.uv0.z);
					col.a *= erode(tex2D(_MaskTex, i.uv1).x, i.uv0.w);
					return col * i.color;
				}
				ENDCG 
			}
		}	
	}
}
