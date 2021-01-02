Shader "Custom/Mino/Skins/Outback Distorted Background"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
		_UtilTex ("Distortion Texture (X = R, Y = G)", 2D) = "grey" { }
		_Util ("Horizontal Distortion (X), Vertical Distortion (Y), Mask Scroll Speed (Z), Ring Width (W)", Vector) = (0.05, 0.05, 0.2, 0.4)
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
			sampler2D _MainTex, _UtilTex;
			half4 _UtilTex_ST, _Util;

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
				OUT.texcoord1 = TRANSFORM_TEX(IN.texcoord, _UtilTex);

				#ifdef PIXELSNAP_ON
					OUT.vertex = UnityPixelSnap(OUT.vertex);
				#endif

				return OUT;
			}

			half4 SpriteFrag(v2f IN): SV_Target
			{
				half3 util = tex2D(_UtilTex, IN.texcoord1).rgb;
				half offsetX = (util.r * 2 - 1) * _Util.x;
				half offsetY = (util.g * 2 - 1) * _Util.y;
				
				half mask = util.b;
				mask = 1 - mask;
				half threshold = sin(_Time.y * _Util.z);
				threshold += 1;
				threshold *= 0.5;
				threshold = abs(mask - threshold);
				mask = 1 - (threshold / _Util.w);

				half3 overlay = tex2D(_MainTex, IN.texcoord0).a * IN.color.rgb * IN.color.a;
				half2 altUV = half2(offsetX, offsetY) * mask;
				altUV += IN.texcoord0;
				half3 col = tex2D(_MainTex, altUV).rgb;

				return half4(col + overlay, 1);
			}
			
			ENDCG
			
		}
	}
}
