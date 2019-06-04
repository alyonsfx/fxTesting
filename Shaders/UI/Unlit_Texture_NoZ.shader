Shader "UI/Simple/Texture"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Overlay" "PreviewType"="Plane" }
		LOD 100
		
		Pass
		{
			ZTest Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 2.0
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			half4 _MainTex_ST;
			
			v2f_img vert (appdata_img v)
			{
				v2f_img o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			half4 frag (v2f_img i) : SV_Target
			{
				return half4 (tex2D(_MainTex, i.uv).xyz,1);

			}
			ENDCG
		}
	}
}