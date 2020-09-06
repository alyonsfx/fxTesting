Shader "Debug/UV Set 1"
{
	SubShader
	{
		Tags { "RenderType" = "Opaque" "PreviewType" = "Plane" }
	
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
				half2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				half4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}
			
			half4 frag( v2f i ) : SV_Target
			{
				half4 c = frac( half4(i.uv, 0, 0) );
				if (any(saturate(i.uv) - i.uv))
					c.b = 0.5;
				return c;
			}
			ENDCG
		}
	}
}