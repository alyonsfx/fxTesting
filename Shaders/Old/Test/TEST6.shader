Shader "Test/Flatten v1"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Range ("Max Height (Worldspace)", Float) = 2
		_Offset ("Max Offset", Float) = 0.5
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
			half _Range, _Offset;

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
				half4 wPos = mul(unity_ObjectToWorld, v.vertex);
				half pct = clamp( wPos.y/ _Range, 0 , 1);
				wPos.z += lerp(0,_Offset, pct);
				o.pos = UnityObjectToClipPos(mul(unity_WorldToObject,wPos));

				//o.pos = UnityObjectToClipPos(v.vertex);
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