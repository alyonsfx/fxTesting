Shader "Unlit/Color"
{
	Properties
	{
		_Color ("Main Color (RGB)", Color) = (1,1,1,1)
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

			half4 _Color;

			struct appdata
			{
				half4 vertex : POSITION;
			};

			struct v2f
			{
				half4 pos : SV_POSITION;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				return half4 (_Color.xyz,1);
			}
			ENDCG
		}
	}
}
