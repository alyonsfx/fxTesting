Shader "Debug/Vertex Color"
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

			struct appdata
			{
				half4 vertex : POSITION;
				half4 color : COLOR;
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
				o.color = v.color;
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