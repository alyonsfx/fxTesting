Shader "Custom/UI/Additive Rotating Mask"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
		_Color ("Mask Color", Color) = (1, 1, 1, 1)
		_Speed ("Rotaion Speed", float) = 0.2
		_Angle ("Start Angle", Range(0.00, 360.00)) = 45
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
		LOD 100

		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" }

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
		Blend SrcAlpha One
		ColorMask [_ColorMask]

		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"
			#include "../DWD_ShaderFunctions.cginc"

			#pragma multi_compile __ UNITY_UI_CLIP_RECT
			#pragma multi_compile __ UNITY_UI_ALPHACLIP

			struct appdata_t
			{
				half4 vertex: POSITION;
				half2 texcoord: TEXCOORD0;
				half4 color: COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				half4 vertex: SV_POSITION;
				half2 texcoord: TEXCOORD0;
				half4 worldPosition: TEXCOORD2;
				half4 color: COLOR;
				half roation: TEXCOORD3;
			};

			sampler2D _MainTex;
			half4 _MainTex_ST, _Color, _ClipRect, _TextureSampleAdd;
			half _Speed, _Angle;
			bool _UseClipRect, _UseAlphaClip;

			v2f vert(appdata_t v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				o.worldPosition = v.vertex;
				o.vertex = UnityObjectToClipPos(o.worldPosition);

				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.color = v.color;

				o.roation = _Angle + frac(_Time.y * _Speed) * 360;

				return o;
			}

			half4 frag(v2f i): COLOR
			{
				half2 tex = (tex2D(_MainTex, i.texcoord) + _TextureSampleAdd).rg;
				half2 modifiedUVs = ComputeRotatedUV(i.texcoord, i.roation);
				half mask = (tex2D(_MainTex, modifiedUVs) + _TextureSampleAdd).b;
				half4 color = i.color * tex.x;
				color.rgb += _Color.rgb * tex.y * mask * _Color.a;
				color.a += tex.y * mask * _Color.a;

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

