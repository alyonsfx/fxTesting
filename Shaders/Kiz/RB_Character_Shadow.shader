// Shadow for characters
Shader "Rocket Boy/Character/Character Drop Shadow"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	Category 
	{
		SubShader 
		{
			Tags { "RenderType"="Transparent" "Queue"="Transparent"}
			Fog { Mode Off }
			Lighting Off
			ZWrite Off
			ZTest On
			Cull Back
			Pass
			{
				Blend Zero OneMinusSrcAlpha
			
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#include "UnityCG.cginc"

				uniform sampler2D _MainTex;
			
				struct appdata
				{
					fixed4 vertex : POSITION;
					fixed4 color : COLOR;
					fixed4 texcoord : TEXCOORD0;
				};
				struct v2f
				{
					fixed4 pos : SV_POSITION;
					fixed2 uv : TEXCOORD0;
					fixed4 color : COLOR0;
				};		
			
				v2f vert (appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.color = v.color;
					o.uv = TRANSFORM_UV(0);
					return o;
				}			
				fixed4 frag (v2f o) : SV_Target
				{
					fixed4 c = tex2D(_MainTex, o.uv);
					c.w *= o.color.w;
					return c;
				}
				ENDCG
			}
		} 
	}
}