Shader "Custom/Sprites/2 Color Gradient"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
		_Top ("Top Point", Range(0.00, 1.00)) = 1.00
		_ColorTop ("Top", Color) = (1, 1, 1, 1)
		_Bottom ("Bottom Point", Range(0.00, 1.00)) = 0.00
		_ColorBot ("Bottom", Color) = (1, 1, 1, 1)
	}

	SubShader
	{
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "False" }

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"

			half4 _ColorTop, _ColorBot;
			half _Top, _Bottom;

			struct appdata
			{
				half4 vertex: POSITION;
				float2 texcoord: TEXCOORD0;
				half4 color: COLOR;
			};

			struct v2f
			{
				half4 vertex: SV_POSITION;
				half4 color: COLOR;
				float2 texcoord: TEXCOORD0;
			};

			v2f vert(appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = v.texcoord;
				return o;
			}

			half4 frag(v2f i): SV_Target
			{
				float temp = min(max(i.texcoord.y - _Bottom, 0) / (_Top - _Bottom), 1);
				float4 c = lerp(_ColorBot, _ColorTop, temp) * i.color;
				c.rgb *= c.a;
				return c;
			}
			
			ENDCG
			
		}
	}
}
