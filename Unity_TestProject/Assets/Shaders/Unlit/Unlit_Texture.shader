Shader "Unlit/Texture"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
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
			half4 _MainTex_ST;

			struct appdata_vu
			{
			    half4 vertex : POSITION;
			    half2 texcoord : TEXCOORD0;
			};

			struct v2f_vu
			{
			    half4 pos : SV_POSITION;
			    half2 uv : TEXCOORD0;
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
				UNITY_OPAQUE_ALPHA(col.a);
				return col;
			}
			ENDCG
		}
	}
}