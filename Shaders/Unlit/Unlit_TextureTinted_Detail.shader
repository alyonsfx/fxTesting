Shader "Unlit/Texture (Tinted Detail)"
{
	Properties
	{
		_Color ("Main Color (RBG) Detail Intensity (A)", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Detail ("Detail ", 2D) = "grey" {}
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

			half4 _Color, _MainTex_ST, _Detail_ST;
			sampler2D _MainTex, _Detail;

			struct appdata_vu
			{
			    half4 vertex : POSITION;
			    half2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				half4 pos : SV_POSITION;
				half2 uv0 : TEXCOORD0;
				half2 uv1 : TEXCOORD1;
			};
			
			v2f vert (appdata_vu v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv0 = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv1 = TRANSFORM_TEX(v.texcoord, _Detail);
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv0) * _Color;
				col.rgb *= lerp(fixed3(1,1,1), tex2D(_Detail, i.uv1).rgb, _Color.a);
				UNITY_OPAQUE_ALPHA(col.a);
				return col;
			}
			ENDCG
		}
	}
}