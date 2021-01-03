Shader "Custom/Mino/Skins/Sydney Water Highlights"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
		[HideInInspector] _Color ("Tint", Color) = (1, 1, 1, 1)
		_MaskTex ("Mask Texture", 2D) = "white" { }
		_Scroll ("Mask Scroll: Red (XY), Green (ZW)", Vector) = (1, 1, 1, 1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[HideInInspector] _RendererColor ("RendererColor", Color) = (1, 1, 1, 1)
		[HideInInspector] _Flip ("Flip", Vector) = (1, 1, 1, 1)
		[PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" { }
		[PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
	}

	SubShader
	{
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "True" }

		Cull Off
		Lighting Off
		ZWrite Off
		Blend SrcAlpha One

		Pass
		{
			CGPROGRAM
			
			#pragma vertex SpriteVert
			#pragma fragment SpriteFrag
			#pragma target 2.0
			#pragma multi_compile_instancing
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
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

			#endif // instancing

			CBUFFER_START(UnityPerDrawSprite)
			#ifndef UNITY_INSTANCING_ENABLED
				half4 _RendererColor;
				half2 _Flip;
			#endif
			float _EnableExternalAlpha;
			CBUFFER_END

			// Material Color.
			sampler2D _MainTex, _AlphaTex, _MaskTex;
			half4 _MaskTex_ST, _Scroll;

			inline half4 UnityFlipSprite(in half3 pos, in half2 flip)
			{
				return half4(pos.xy * flip, pos.z, 1.0);
			}

			half4 SampleSpriteTexture(half2 uv)
			{
				half4 color = tex2D(_MainTex, uv);

				#if ETC1_EXTERNAL_ALPHA
					half4 alpha = tex2D(_AlphaTex, uv);
					color.a = lerp(color.a, alpha.r, _EnableExternalAlpha);
				#endif

				return color;
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
				half texcoord0: TEXCOORD0;
				half4 texcoord1: TEXCOORD1;
			};

			v2f SpriteVert(appdata_t IN)
			{
				v2f OUT;

				OUT.vertex = UnityFlipSprite(IN.vertex, _Flip);
				OUT.vertex = UnityObjectToClipPos(OUT.vertex);
				OUT.texcoord0 = IN.texcoord;
				OUT.texcoord1.xy = TRANSFORM_TEX(IN.texcoord, _MaskTex) + frac(half2(_Scroll.x, _Scroll.y) * _Time.y);
				OUT.texcoord1.zw = TRANSFORM_TEX(IN.texcoord, _MaskTex) + frac(half2(_Scroll.z, _Scroll.w) * _Time.y);
				OUT.color = IN.color;

				#ifdef PIXELSNAP_ON
					OUT.vertex = UnityPixelSnap(OUT.vertex);
				#endif

				return OUT;
			}

			half4 SpriteFrag(v2f IN): SV_Target
			{
				half4 sprite = SampleSpriteTexture(IN.texcoord0);
				half highlight1 = tex2D(_MaskTex, IN.texcoord1.xy).r;
				half highlight2 = tex2D(_MaskTex, IN.texcoord1.zw).g;
				half4 col = sprite * IN.color * saturate(highlight1 + highlight2);
				col.rgb *= col.a;
				return col;
			}
			
			ENDCG
			
		}
	}
}
