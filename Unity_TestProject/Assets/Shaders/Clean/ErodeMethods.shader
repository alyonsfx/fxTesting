Shader "Unlit/Erode Methods"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_Erode ("Dissolve Amount", Range(0, 1)) = 0
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 2.0
			
			#include "UnityCG.cginc"
			#include "../Andrew.cginc"

			sampler2D _MainTex;
			half4 _MainTex_ST;
			half _Erode;
			
			v2f_VU vert(appdata_VU v)
			{
				v2f_VU o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv0 = TRANSFORM_TEX(v.texcoord0, _MainTex);
				return o;
			}
			
			half4 frag(v2f_VU i): SV_Target
			{
				half tex = tex2D(_MainTex, i.uv0).r;
				//return tex * step(_Erode, tex);
				return smoothErode(tex, _Erode);
				//return smoothstep(_Erode, 1, tex);
				//return saturate(tex * (1.0 / (1 - _Erode)) - (_Erode / (1 - _Erode)));
			}
			ENDCG
			
		}
	}
}
