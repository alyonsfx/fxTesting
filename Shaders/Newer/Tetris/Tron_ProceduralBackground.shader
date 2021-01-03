Shader "Custom/Mino/Skins/Tron Procedural Background"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
		_GridTex ("Pixel Grid Texture", 2D) = "black" { }
		[NoScaleOffset] _ScanlineTex ("Scanline Texture", 2D) = "white" { }
		[Header(Pixel Speed(X)  Pixel Min(Y)  Pixel Max(Z)  Grid Intensity(W))]
		_Util1 ("", Vector) = (0.1, 0.15, 0.275, 0.4)
		[Header(Ring Width(X)  TBD(Y)  Scanline Scale(Z)  Scanline Speed(W))]
		_Util2 ("", Vector) = (0.1, 0.3, 40, -0.5)
		[PowerSlider(3.0)] _DistortionIntensity ("Distortion Intensity", Range(0.00, 1.00)) = 0.3
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

			// Material Color.
			sampler2D _MainTex, _GridTex, _ScanlineTex;
			half4 _Util1, _Util2, _GridTex_ST;
			half _DistortionIntensity, _PulseOffset;

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
				half2 texcoord1: TEXCOORD1;
				half4 texcoord2: TEXCOORD2;
			};

			v2f SpriteVert(appdata_t IN)
			{
				v2f OUT;

				OUT.vertex = UnityFlipSprite(IN.vertex, _Flip);
				OUT.vertex = UnityObjectToClipPos(OUT.vertex);
				OUT.color = IN.color;

				// Main sprite UVs
				OUT.texcoord0 = IN.texcoord;
				// UVs for the value scrolling pixels and the grid
				OUT.texcoord1 = TRANSFORM_TEX(IN.texcoord, _GridTex);
				// Screenspace info for the pulse and scanlines
				OUT.texcoord2 = ComputeScreenPos(OUT.vertex);

				#ifdef PIXELSNAP_ON
					OUT.vertex = UnityPixelSnap(OUT.vertex);
				#endif

				return OUT;
			}

			half4 SpriteFrag(v2f IN): SV_Target
			{
				// Sprite texture
				half pixelMask = tex2D(_MainTex, IN.texcoord0).r;

				half2 screenPos = IN.texcoord2.xy / IN.texcoord2.w;
				// The ring mask for the distortion pulse
				half dist = distance(screenPos, half2(0.5, 0.5)) - _PulseOffset;
				half ring = (1 - (abs(dist) / _Util2.x)) * ((dist - _Util2.x) < 0 && (dist + _Util2.x) > 0);

				// Use this for UV distortion
				screenPos *= 2;
				screenPos += half2(-1, -1);
				screenPos *= ring;

				half2 patterns = tex2D(_GridTex, half2(IN.texcoord1 - screenPos * _DistortionIntensity)).rg;
				half grid = patterns.r * pixelMask * _Util1.w * saturate(IN.color.a * 2);
				half pixels = frac(patterns.g + _Time.y * _Util1.x);
				half y = frac(IN.texcoord2.y * _Util2.z + _Time.x * _Util2.w);
				half scan = tex2D(_ScanlineTex, half2(0, y));

				half4 col = IN.color;
				col.rgb *= clamp(pixels, _Util1.y, _Util1.z) * pixelMask * IN.color.a;
				col.rgb += grid.xxx;
				col.rgb *= scan;
				col.a = 1;

				return col;
			}
			
			ENDCG
			
		}
	}
}
