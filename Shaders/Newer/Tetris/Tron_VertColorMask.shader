// Uses vertex color (RGB) as a mask
// Blends between the Main Texture and black based on the mask

Shader "Custom/Mino/Skins/Tron Vert Color Mask"
{
	Properties
	{
		_Color ("MainTint", Color) = (1, 1, 1, 1)
		_MainTex ("Base (RGB)", 2D) = "white" { }
	}

	SubShader
	{
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" }

		Pass
		{
			Blend SrcAlpha One
			ZWrite Off
			Cull Off
			Lighting Off
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			half4 _Color, _MainTex_ST;

			struct appdata
			{
				float4 vertex: POSITION;
				half2 texcoord0: TEXCOORD0;
				half4 color: COLOR;
			};

			struct v2f
			{
				float4 pos: SV_POSITION;
				half2 uv: TEXCOORD0;
				half color: COLOR;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord0, _MainTex);
				o.color = 1 - clamp(v.color.r, 0, 1);
				return o;
			}

			half4 frag(v2f i): SV_Target
			{
				half3 tex = tex2D(_MainTex, i.uv).rgb * _Color.rgb * i.color.x ;
				return half4(tex, 1);
			}
			ENDCG
			
		}
	}
}
