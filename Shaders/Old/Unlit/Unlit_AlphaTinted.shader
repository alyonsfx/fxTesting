Shader "Unlit/Transparent (Tinted)"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)  Trans (A)", 2D) = "white" {}
	}

	SubShader
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 2.0
			
			#include "UnityCG.cginc"

			fixed4 _Color, _MainTex_ST;
			sampler2D _MainTex;

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
			
			fixed4 frag (v2f_vu i) : SV_Target
			{
				return tex2D(_MainTex, i.uv) * _Color;
			}
			ENDCG
		}
	}
}