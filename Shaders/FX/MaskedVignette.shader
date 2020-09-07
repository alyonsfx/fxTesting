Shader "Custom/Camera/Masked Vignette"
{
	Properties
	{
		[PerRendererData] _MainTex ("LEAVE THIS BLANK", 2D) = "white" {}
		_Intensity("Intensity", Float) = 1
		_Color("Main Tint", Color) = (1,1,1,1)
		_MaskTex ("Mask Texture (R)", 2D) = "white" {}
		//_Saturation ("Saturation", float) = 1
	}

	SubShader
	{
//		Pass 
//		{
//			CGPROGRAM
//			#pragma vertex vert_img
//			#pragma fragment frag
//			#include "UnityCG.cginc"
//
//			uniform sampler2D _MainTex;
//			fixed _Intensity;
//
//			float4 frag(v2f_img i) : COLOR
//			{
//				fixed4 c = tex2D(_MainTex, i.uv);
//
//				fixed3 bw = (c.r*.3 + c.g*.59 + c.b*.11).xxx;
//
//				c.rgb = lerp(c.rgb, bw, _Intensity);
//				return c;
//			}
//			ENDCG
//		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#include "UnityCG.cginc"
		
			uniform sampler2D _MainTex, _MaskTex;
			half _Intensity;
			half4 _Color;

			half4 frag (v2f_img i) : COLOR
			{
				half4 base = tex2D(_MainTex, i.uv);
				half4 col = tex2D(_MaskTex, i.uv);
				col = lerp(base, _Color, col.x);
				col = lerp(base, col, _Intensity);
				return col;
			}
			ENDCG
		}
	}
}