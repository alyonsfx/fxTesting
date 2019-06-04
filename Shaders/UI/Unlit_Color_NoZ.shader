Shader "UI/Simple/Color"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Overlay" "PreviewType"="Plane" }
		LOD 100
		
		Pass
		{  
			Ztest NotEqual

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 2.0
			
			#include "UnityCG.cginc"

			struct appdata_t
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				half4 pos : SV_POSITION;
			};

			half4 _Color;
			
			v2f vert (appdata_t v)
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
