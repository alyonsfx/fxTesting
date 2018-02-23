Shader "Unlit/Transparent Cutout (Tinted)"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5
	}

	SubShader
	{
		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
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

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _Cutoff;
			
			v2f_img vert (appdata_img v)
			{
				v2f_img o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f_img i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) * _Color;
				clip(col.a - _Cutoff);
				return col;
			}
			ENDCG
		}
	}
}