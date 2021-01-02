//© Dicewrench Designs LLC 2020
//All Rights Reserved, used with permission
//Last Owned by: Allen White (allen@dicewrenchdesigns.com)


Shader "Custom/DWD/Sprites/Scrolling Shine"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
		_Color ("Tint", Color) = (1, 1, 1, 1)

		[KeywordEnum(Default, Mask)] _SpriteMode ("Sprite Mode", Float) = 0.0
		[Header(Mask Settings)]
		_RedColor ("Red Color", Color) = (1, 1, 1, 1)
		_RedShine ("Red Shine", Range(0, 1)) = 0.0
		[Space]
		_GreenColor ("Green Color", Color) = (1, 1, 1, 1)
		_GreenShine ("Green Shine", Range(0, 1)) = 0.0
		[Space]
		_BlueColor ("Blue Color", Color) = (1, 1, 1, 1)
		_BlueShine ("Blue Shine", Range(0, 1)) = 0.0
		[Space]
		_NoColor ("No Color", Color) = (1, 1, 1, 1)
		_NoShine ("No Shine", Range(0, 1)) = 0.0

		[Header(Shine Settings)]
		_ShineTex ("Shine Texture", 2D) = "white" { }
		[Space]
		_UVAngle ("UV Angle", Range(0, 360)) = 0.0
		[KeywordEnum(UV, Screen, World)] _UVMode ("UV Mode", Float) = 0.0
		_Scroll ("Scroll Rate", Float) = 0.0
		[Space]
		_ShineColor ("Shine Color", Color) = (1, 1, 1, 1)
		_ShineScale ("Shine Cutoff", Range(-1, 1)) = 0.1
		_ShineFrequency ("Shine Frequency", Float) = 2.0
		_ShineContrast ("Shine Contrast", Float) = 1.0
		_ShineIntensityBoost ("Shine Intensity Boost", Range(1, 4)) = 1.0

		[Header(Level Up Shine)]
		_LevelShineProgress ("Shine Progress", Float) = 0.0
		[Space]
		_LevelShineColor ("Shine Color", Color) = (1, 1, 1, 1)
		_LevelShineScale ("Shine Cutoff", Range(-1, 1)) = 0.1
		_LevelShineContrast ("Shine Pow", Float) = 1.0
		_LevelShineBoost ("Shine Boost", Float) = 40.0

		[Space]

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
		Blend One OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#pragma multi_compile _SPRITEMODE_DEFAULT _SPRITEMODE_MASK
			#pragma multi_compile _UVMODE_UV _UVMODE_SCREEN _UVMODE_WORLD
			#pragma multi_compile_instancing
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA

			#include "UnitySprites.cginc"
			#include "../DWD_ShaderFunctions.cginc"

			fixed4 _RedColor, _GreenColor, _BlueColor, _NoColor;
			float _RedShine, _GreenShine, _BlueShine, _NoShine;

			sampler2D _ShineTex;
			uniform float4 _ShineTex_ST;
			float _Scroll, _UVAngle;
			float _ShineContrast, _ShineScale, _ShineFrequency, _ShineIntensityBoost;
			fixed4 _ShineColor;

			float _LevelShineContrast, _LevelShineProgress, _LevelShineScale, _LevelShineBoost;
			fixed4 _LevelShineColor;

			struct fragInput
			{
				float4 vertex: SV_POSITION;
				fixed4 color: COLOR;
				float4 coords: TEXCOORD0;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			fragInput vert(appdata_t IN)
			{
				fragInput OUT;

				OUT.vertex = UnityFlipSprite(IN.vertex, _Flip);
				OUT.vertex = UnityObjectToClipPos(OUT.vertex);

				float2 uv = IN.texcoord.xx;

				#if _UVMODE_UV

				#elif _UVMODE_SCREEN
					uv = OUT.vertex.xy * float2(1.0, -1.0);
				#elif _UVMODE_WORLD
					float3 worldPos = mul(unity_ObjectToWorld, IN.vertex).xyz;
					uv = ComputeRotatedUV(worldPos.xy, _UVAngle);
				#endif

				OUT.coords.xy = IN.texcoord;
				OUT.coords.zw = uv;
				OUT.color = IN.color * _Color * _RendererColor;

				#ifdef PIXELSNAP_ON
					OUT.vertex = UnityPixelSnap(OUT.vertex);
				#endif

				return OUT;
			}

			half4 frag(fragInput IN): SV_Target
			{
				half4 c = SampleSpriteTexture(IN.coords.xy);
				half alpha = c.a;
				fixed mask = 1.0;
				fixed shineMask = 1.0;
				float2 baseShineUV = IN.coords.zw;

				#if _SPRITEMODE_MASK
					fixed4 redColor = _RedColor * c.rrrr;
					fixed4 greenColor = _GreenColor * c.gggg;
					fixed4 blueColor = _BlueColor * c.bbbb;
					mask = 1.0 - saturate(c.r + c.g + c.b);
					fixed4 noColor = _NoColor * mask.xxxx;

					fixed redShine = _RedShine * c.r;
					fixed greenShine = _GreenShine * c.g;
					fixed blueShine = _BlueShine * c.b;
					fixed noShine = _NoShine * mask;

					shineMask = saturate(redShine + greenShine + blueShine + noShine);

					c = saturate(redColor + greenColor + blueColor + noColor) * IN.color;
				#elif _SPRITEMODE_DEFAULT
					c *= IN.color;
				#endif

				#if _UVMODE_UV
					IN.coords.zw = ComputeRotatedUV((IN.coords.xy), _UVAngle);
					baseShineUV = IN.coords.zw;
					IN.coords.zw = CalculateShine(IN.coords.zw, _ShineScale, _ShineFrequency, _Scroll);
				#elif _UVMODE_SCREEN
					IN.coords.zw = GetScreenUV(ComputeRotatedUV(IN.coords.zw, _UVAngle), float4(1.0, 1.0, -1.0, 0.0));
					baseShineUV = IN.coords.zw;
					IN.coords.zw = CalculateShine(IN.coords.zw, _ShineScale, _ShineFrequency, _Scroll);
				#elif _UVMODE_WORLD
					IN.coords.zw = CalculateShine(IN.coords.zw * 0.04.xx, _ShineScale, _ShineFrequency, _Scroll);
				#endif

				fixed s = tex2D(_ShineTex, (IN.coords.xy * _ShineTex_ST.xy) + _ShineTex_ST.zw).r;
				fixed grad = s * saturate(pow(IN.coords.z, _ShineContrast) * _ShineContrast);

				fixed3 mix = saturate(lerp(c.rgb, ApplyOverlay(c.rgb, _ShineColor.rgb), grad * _ShineColor.a * _ShineIntensityBoost * shineMask));
				mix *= alpha.xxx;

				fixed level = baseShineUV.x - (_LevelShineProgress * 2.0 - 1.0);
				level = abs((level * 2.0) - 1.0);



				level = saturate(pow(level - _LevelShineScale, _LevelShineContrast) * _LevelShineBoost) * _LevelShineColor.a * shineMask * s;
				fixed3 levelShine = _LevelShineColor.rgb * level.xxx;
				mix += levelShine;

				#if _SPRITEMODE_MASK
					mix *= alpha.xxx;
				#endif

				return fixed4(mix, alpha);
			}
			
			ENDCG
			
		}
	}
}