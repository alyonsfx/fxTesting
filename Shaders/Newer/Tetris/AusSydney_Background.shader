Shader "Custom/Mino/Skins/Sydney Background"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
		_RingWidth ("Ring Width", Float) = 0.1
		_RingFalloff ("Ring Falloff", Float) = 1
		_RingOffset ("Pulse Offset", Range(0.00, 1.00)) = 0
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
			half _RingFalloff, _RingWidth, _RingOffset;

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
				half4 tex = tex2D(_MainTex, IN.texcoord0);
				half mask = tex.a;

				half aspectRatio = (_ScreenParams.x / _ScreenParams.y);
				half2 screenPos = IN.texcoord1.xy / IN.texcoord1.w;
				screenPos.x *= aspectRatio;
				half dist = distance(screenPos, half2(0.5 * aspectRatio, 0));
				dist = abs(dist - _RingOffset);
				half ring = 1 - pow((dist / _RingWidth), _RingFalloff);
				ring *= ((dist - _RingWidth) < 0 && (dist + _RingWidth) > 0);
				
				half3 col = tex.rgb + IN.color.rgb * IN.color.a * mask;
				col = lerp(tex, col, clamp(ring, 0, 1));
				return half4(col, 1);
			}
			ENDCG
			
		}
	}
}
