Shader "Custom/UI/Minigame Booster Button"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }

		[Header(Custom)]
		_Progress ("Progress", Range(0.00, 1.00)) = 0.5
		_RemainingDark ("Remaining Darken", Range(0.00, 1.00)) = 0.8
		_Boost ("Boost Amount", Range(0.00, 1.00)) = 0
		[MainColor]_GlowColor ("Inner Glow Color", Color) = (1, 1, 1, 0)
		_GlowRadius ("Inner Glow Radius", Range(0.00, 1.00)) = 0.3
		_GlowHardness ("Inner Glow Hardness", Float) = 0.6
		_ShineBoost ("Shine Boost", Range(0.00, 1.00)) = 0.3
		_ShineAngle ("Shine Angle", Range(-180.0, 180)) = -45
		_ShineOffset ("Shine Offset", Float) = 0.3
		_ShineWidth ("Shine Width", Range(0.00, 0.50)) = 0.3
		_ShineFalloff ("Shine Falloff", Range(0.00, 2.00)) = 0.3

		[Header(Default UI)]
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
	}

	SubShader
	{
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "True" }

		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		Pass
		{
			Name "Default"
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"
			#include "../DWD_ShaderFunctions.cginc"
			#include "../N3twork.cginc"

			#pragma multi_compile __ UNITY_UI_CLIP_RECT
			#pragma multi_compile __ UNITY_UI_ALPHACLIP

			struct appdata_t
			{
				half4 vertex: POSITION;
				float2 texcoord: TEXCOORD0;
				half4 color: COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				half4 vertex: SV_POSITION;
				float2 texcoord: TEXCOORD0;
				half4 worldPosition: TEXCOORD2;
				half4 color: COLOR;
			};

			sampler2D _MainTex;
			half4 _MainTex_ST, _ClipRect, _TextureSampleAdd, _GlowColor;
			half _Progress, _Boost, _RemainingDark;
			half _GlowRadius, _GlowHardness;
			half _ShineBoost, _ShineAngle, _ShineOffset;
			float _ShineFalloff, _ShineWidth;
			bool _UseClipRect, _UseAlphaClip;

			v2f vert(appdata_t v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				o.worldPosition = v.vertex;
				o.vertex = UnityObjectToClipPos(o.worldPosition);

				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.color = v.color;

				return o;
			}

			half4 frag(v2f i): COLOR
			{
				float2 UVs = i.texcoord;
				half4 tex = (tex2D(_MainTex, UVs) + _TextureSampleAdd);
				half mask = step(UVs.y, _Progress);
				half3 boost = tex.rgb * _Boost;

				half desat = greyscale(tex.rgb) * _RemainingDark;
				half4 color;
				half3 edgeGlow = _GlowColor.rgb * _GlowColor.a;
				edgeGlow *= saturate((distance(UVs, half2(0.5, 0.5)) - _GlowRadius) / (1 - _GlowHardness));
				color.rgb = lerp(tex.rgb + boost, desat, mask) + edgeGlow;

				float modifiedUV = ComputeRotatedUV(UVs, _ShineAngle).x;
				float dist = distance(modifiedUV, 0.5f + _ShineOffset);
				dist = pow(dist, _ShineFalloff);
				float highlight = (1 - (abs(dist) / _ShineWidth)) * ((dist - _ShineWidth) < 0 && (dist + _ShineWidth) > 0);

				color.rgb += highlight * _ShineBoost;
				color.a = tex.a;
				color *= i.color;

				#ifdef UNITY_UI_CLIP_RECT
					color.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
				#endif

				#ifdef UNITY_UI_ALPHACLIP
					clip(color.a - 0.001);
				#endif

				return color;
			}
			ENDCG
			
		}
	}
}

