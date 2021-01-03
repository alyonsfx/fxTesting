Shader "Custom/Sprites/3 Color Gradient"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
		_Top ("Top Point", Range(0.00, 1.00)) = 1.00
		_ColorTop ("Top", Color) = (1, 1, 1, 1)
		_Middle ("Mid Point", Range(0.00, 1.00)) = 0.50
		_ColorMid ("Middle", Color) = (0.5, 0.5, 0.5, 0.5)
		_Bottom ("Bottom Point", Range(0.00, 1.00)) = 0.00
		_ColorBot ("Bottom", Color) = (0, 0, 0, 0)
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

			half4 _ColorTop, _ColorMid, _ColorBot;
			half _Top, _Middle, _Bottom;

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
				o.texcoord = v.texcoord;
				o.color = v.color;

				return o;
			}

			half4 frag(v2f i): SV_Target
			{
				float temp = min(max(i.texcoord.y - _Bottom, 0) / (_Top - _Bottom), 1);
				float4 col = _ColorBot + (_ColorMid - _ColorBot) * (min(temp, _Middle) / _Middle) + (_ColorTop - _ColorMid) * (max(temp - _Middle, 0) / (1 - _Middle));
				col *= i.color;
				col.rgb *= col.a;
				return col;
			}
			
			ENDCG
			
		}
	}
}
