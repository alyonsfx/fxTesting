// Unlit alpha-cutout shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "Rocket Boy/HP Bar"
{
	Properties
	{
		_Color("Color Tint", Color) = (0, 0, 0, 1)
		_ClearColor("Clear Color", Color) = (0, 0, 0, 0)
		_Alpha("Global Alpha", Range(0, 1)) = 1
		_Fill("Fill", Range(0, 1)) = 0.5
	}
		SubShader
	{
		Tags {"Queue" = "Overlay" "IgnoreProjector" = "True" "RenderType" = "Transparent"}

		Fog { Mode Off }
		Lighting Off
		ZWrite Off
		ZTest Off
		Cull Back
		ColorMask RGB

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest

				#include "UnityCG.cginc"

				struct appdata_t
				{
					fixed4 vertex : POSITION;
					fixed3 color : COLOR0;
				};

				struct v2f
				{
					fixed4 vertex : SV_POSITION;
					fixed3 color : COLOR0;
				};

				fixed _Fill;
				fixed _Alpha;
				fixed4 _ClearColor;
				fixed4 _Color;

				v2f vert(appdata_t v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.color = v.color;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					// Removed if statement for performance (MVN)
					// Result of sign is -1 if below fill
					int isVisible = clamp(sign(_Fill - i.color.r), 0.0, 1.0);
					fixed4 col = lerp(_ClearColor, _Color, isVisible);
					col.a *= _Alpha;
					return col;
				}
			ENDCG
		}
	}
}
