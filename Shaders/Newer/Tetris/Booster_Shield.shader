Shader "Custom/Mino/Booster Shield"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
		_Boost ("Boost", Range(0.00, 1.00)) = 0.00
		_Threshold ("Vertical Mask Threshold", Float) = 0.5
		_Falloff ("Vertical Mask Falloff", Float) = .1
		_PatternSpeed ("Pattern Speed", Float) = .25
		_PatternIntensity ("Pattern Inensity", Range(0, 1)) = 0
		_PatternLimit ("Pattern Limit", Range(0.00, 1.00)) = .25
		[NoScaleOffset] _OverlayTex ("Overlay Texture", 2D) = "white" { }
		_OverlayScale ("Overlay Scale", Float) = 1
		_NoiseSpeed ("Noise Speed", Float) = .25
		_NoiseIntensity ("Noise Inensity", Range(0, 1)) = 0
		_Distortion ("Distortion", Range(0.00, 1.00)) = 0
		_DistortionSpeed ("Distortion Speed", Float) = .25

		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[HideInInspector] _RendererColor ("RendererColor", Color) = (1, 1, 1, 1)
		[HideInInspector] _Flip ("Flip", Vector) = (1, 1, 1, 1)
		[PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
	}

	SubShader
	{
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "True" }

		Blend SrcAlpha One
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

			sampler2D _MainTex, _OverlayTex;
			half _Boost, _Falloff, _Threshold, _PatternSpeed, _PatternIntensity, _PatternLimit, _OverlayScale, _NoiseSpeed, _NoiseIntensity, _Distortion, _DistortionSpeed;

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

				OUT.texcoord0 = IN.texcoord;
				OUT.texcoord1 = ComputeScreenPos(OUT.vertex);

				#ifdef PIXELSNAP_ON
					OUT.vertex = UnityPixelSnap(OUT.vertex);
				#endif

				return OUT;
			}

			half4 SpriteFrag(v2f IN): SV_Target
			{
				half2 uvs = IN.texcoord0;
				half4 tex = tex2D(_MainTex, uvs);

				half2 screenPos = IN.texcoord1.xy / IN.texcoord1.w;
				half3 overlayTex = tex2D(_OverlayTex, screenPos * _OverlayScale).rgb;

				half mask = tex.g;

				half reveal = step(1 - _Threshold, tex.b);

				half pattern = frac(tex.a + _Time.y * _PatternSpeed) * 2 - 1;
				pattern = lerp(1, abs(pattern), _PatternIntensity);
				pattern = clamp(pattern, _PatternLimit, 1);

				half noise = overlayTex.z;
				noise = frac(noise + _Time.y * _NoiseSpeed) * 2 - 1;
				noise = lerp(1, abs(noise), _NoiseIntensity);

				half offsetX = frac(overlayTex.x + _Time.y * _DistortionSpeed) * 2 - 1;
				offsetX = abs(offsetX) * 2 - 1;
				half offsetY = frac(overlayTex.y + _Time.y * _DistortionSpeed) * 2 - 1;
				offsetY = abs(offsetY) * 2 - 1;
				half2 distortedUVs = half2(offsetX, offsetY) * (_Distortion / 100);
				half shield = saturate(tex2D(_MainTex, uvs + distortedUVs).r + _Boost);

				half4 col = IN.color * mask * saturate(reveal) * pattern * noise * shield;
				return col;
			}
			
			ENDCG
			
		}
	}
}
