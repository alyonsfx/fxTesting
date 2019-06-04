Shader "Custom/Progressbar"
{
	Properties
	{
		_Color ("Base Color", Color) = (0,0,0,1)
		_TintColor ("Tint Color", Color) = (1,1,1,1)
		_MainTex ("Bar (Greyscale) Mask (A)", 2D) = "white" {}
		_Progress ("Progress", Range (0,1)) = 0
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry" }
		LOD 100
		
		Pass
		{  
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 2.0
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			half4 _MainTex_ST, _Color, _TintColor;
			half _Progress;

			struct appdata_vu
			{
			    float4 vertex : POSITION;
			    float2 texcoord : TEXCOORD0;
			};

			struct v2f_vu
			{
			    float4 pos : SV_POSITION;
			    float2 uv : TEXCOORD0;
			};
			
			v2f_vu vert (appdata_vu v)
			{
				v2f_vu o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			half4 frag (v2f_vu i) : SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv);
				half p = floor(col.r + _Progress);
				half m = col.a;
				col = lerp(_Color, _TintColor, p*m);
				UNITY_OPAQUE_ALPHA(col.a);
				return col;
			}
			ENDCG
		}
	}
}