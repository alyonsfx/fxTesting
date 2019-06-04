Shader "Debug/Normals"
{
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 2.0
			
			#include "UnityCG.cginc"

			struct appdata {
				half4 vertex : POSITION;
				half3 normal : NORMAL;
			};

			struct v2f
			{
				half4 pos : SV_POSITION;
				half4 color : COLOR;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color.xyz = v.normal * 0.5 + 0.5;
				o.color.w = 1.0;
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				return i.color;
			}
			ENDCG
		}
	}
}