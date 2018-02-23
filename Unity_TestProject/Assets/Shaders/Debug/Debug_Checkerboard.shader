Shader "Debug/Worldspace Checkerboard"
{
	Properties
	{
		_BaseScale("Tiling (XYZ)", Vector) = (1,1,1,0)
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 2.0

			#include "UnityCG.cginc"

			half3 _BaseScale;
			
			struct appdata
			{
				half4 vertex : POSITION;
			};
			
			struct v2f
			{
				half4 pos : POSITION;
				half3 uv : TEXCOORD0;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = mul(unity_ObjectToWorld, v.vertex);
				o.uv *= _BaseScale;
				return o;
			}

			half4 frag (v2f i) : SV_Target
			{
				half3 worldPos = floor(i.uv + half3(0.001, 0.001, 0.001));
				int sum = worldPos.x + worldPos.y + worldPos.z;
				half mod = abs(fmod(sum, 2.0));
				half4 col = lerp(half4(1,1,1,1), half4(0.5,0.5,0.5,1), mod);
				col.a = 1;
				return col;
			}
			ENDCG
		}
	}
}