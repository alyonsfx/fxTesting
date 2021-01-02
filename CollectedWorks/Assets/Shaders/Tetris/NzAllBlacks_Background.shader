Shader "Custom/Mino/Skins/All Blacks Background"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
		[HideInInspector] _FlashBoost ("Flash Boost", Float) = 0.5
		_IdleBoost ("Idle Detail Boost", Float) = 0.05
		_IdleSpeed ("Idle Speed", Float) = 1
		_RingWidth ("Ring Width(X)", Float) = 0.1
		_PulseOffset ("Pulse Offset", Range(-1.00, 2.00)) = 0
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[HideInInspector] _RendererColor ("RendererColor", Color) = (1, 1, 1, 1)
		[HideInInspector] _Flip ("Flip", Vector) = (1, 1, 1, 1)
		[PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
	}

	SubShader
	{
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "True" }

		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off
		Lighting Off
		ZWrite Off

		Pass
		{
			CGPROGRAM
			
			#pragma vertex SpriteVert
			#pragma fragment SpriteFrag
			#pragma target 2.0
			#pragma multi_compile_instancing
			#pragma multi_compile _ PIXELSNAP_ON
			#include "UnityCG.cginc"

			#ifdef UNITY_INSTANCING_ENABLED

				UNITY_INSTANCING_BUFFER_START(PerDrawSprite)
				// SpriteRenderer.Color while Non-Batched/Instanced.
				UNITY_DEFINE_INSTANCED_PROP(fixed4, unity_SpriteRendererColorArray)
				// this could be smaller but that's how bit each entry is regardless of type
				UNITY_DEFINE_INSTANCED_PROP(fixed2, unity_SpriteFlipArray)
				UNITY_INSTANCING_BUFFER_END(PerDrawSprite)

				#define _RendererColor  UNITY_ACCESS_INSTANCED_PROP(PerDrawSprite, unity_SpriteRendererColorArray)
				#define _Flip           UNITY_ACCESS_INSTANCED_PROP(PerDrawSprite, unity_SpriteFlipArray)

			#endif

			// instancing
			CBUFFER_START(UnityPerDrawSprite)
			#ifndef UNITY_INSTANCING_ENABLED
				half4 _RendererColor;
				half2 _Flip;
			#endif
			CBUFFER_END

			sampler2D _MainTex;
			half _FlashBoost, _IdleBoost, _IdleSpeed, _RingWidth, _PulseOffset;

			inline half4 UnityFlipSprite(in half3 pos, in half2 flip)
			{
				return half4(pos.xy * flip, pos.z, 1.0);
			}

			struct appdata_t
			{
				half4 vertex: POSITION;
				half4 color: COLOR;
				half2 texcoord: TEXCOORD0;
			};

			struct v2f
			{
				half4 vertex: SV_POSITION;
				half4 color: COLOR;
				half2 texcoord0: TEXCOORD0;
				half4 texcoord1: TEXCOORD1;
			};

			v2f SpriteVert(appdata_t IN)
			{
				v2f OUT;

				OUT.vertex = UnityFlipSprite(IN.vertex, _Flip);
				OUT.vertex = UnityObjectToClipPos(OUT.vertex);
				OUT.color = IN.color;

				// Main sprite UVs
				OUT.texcoord0 = IN.texcoord;
				OUT.texcoord1 = ComputeScreenPos(OUT.vertex);

				#ifdef PIXELSNAP_ON
					OUT.vertex = UnityPixelSnap(OUT.vertex);
				#endif

				return OUT;
			}

			half4 SpriteFrag(v2f IN): SV_Target
			{
				half2 tex = tex2D(_MainTex, IN.texcoord0).rg;
				half intensity = IN.color.a + _IdleBoost * sin(_Time.y * _IdleSpeed) + _FlashBoost;
				half details = tex.x * intensity * tex.y;

				half aspectRatio = (_ScreenParams.x / _ScreenParams.y);
				half2 screenPos = IN.texcoord1.xy / IN.texcoord1.w;
				screenPos.x *= aspectRatio;
				half dist = distance(screenPos, half2(0.5 * aspectRatio, 0.5)) - _PulseOffset;
				half ring = (1 - (abs(dist) / _RingWidth)) * ((dist - _RingWidth) < 0 && (dist + _RingWidth) > 0);
				half3 highlight = IN.color.rgb + details;
				highlight *= tex.x;

				half4 col;
				col.rgb = lerp(details.xxx, highlight, ring);
				col.a = 1;
				return col;
			}
			
			ENDCG
			
		}
	}
}
