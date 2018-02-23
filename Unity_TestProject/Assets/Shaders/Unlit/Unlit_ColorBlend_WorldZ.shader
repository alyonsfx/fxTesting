Shader "Unlit/Color Blend (Worldspace Z)"
{
	Properties
	{
		_Color1 ("Color 1", Color) = (1,1,1,1)
		_Color2 ("Color 2", Color) = (0,0,0,1)
		_Offset ("Z Scale", float) = 1
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

			sampler2D _MainTex;
			half4 _MainTex_ST, _TintColor, _Color1, _Color2;
			half _Offset;
			
			struct appdata
			{
				half4 vertex : POSITION;
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
				half worldPos = mul (unity_WorldToObject, v.vertex).z;
				worldPos *= _Offset * 0.1;
				worldPos += 0.5;
				o.color = lerp(_Color1, _Color2, worldPos);

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