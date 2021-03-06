Shader "Particles/Alpha Blended (Gradient Remap)"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex("Particle Texture (Greyscale)", 2D) = "white" { }
		[NoScaleOffset] _RampTex("Color Remap Texture", 2D) = "white" { }
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
	}
	
	SubShader
	{
		Pass
		{
			Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			Cull Off
			Lighting Off
			ZWrite Off
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#pragma multi_compile_particles
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex, _RampTex;
			fixed4 _TintColor;

			struct appdata
			{
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed4 color : COLOR0;
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
#ifdef SOFTPARTICLES_ON
				float4 projPos : TEXCOORD2;
#endif
				UNITY_VERTEX_OUTPUT_STEREO
			};
			
			float4 _MainTex_ST, _RampTex_ST;

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.pos = UnityObjectToClipPos(v.vertex);
#ifdef SOFTPARTICLES_ON
				o.projPos = ComputeScreenPos (o.pos);
				COMPUTE_EYEDEPTH(o.projPos.z);
#endif
				o.color = saturate(v.color);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			
			sampler2D_float _CameraDepthTexture;
			float _InvFade;

			fixed4 frag(v2f i) : SV_Target
			{
#ifdef SOFTPARTICLES_ON
				float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
				float partZ = i.projPos.z;
				float fade = saturate (_InvFade * (sceneZ-partZ));
				i.color.a *= fade;
#endif
				fixed4 tex = tex2D(_MainTex, i.uv.xy);
				fixed4 col = tex2D(_RampTex, fixed2(tex.x,0.5));
				col.a = tex.a;
				col *= 2.0f* i.color * _TintColor;
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
	FallBack "Particles/Alpha Blended"
}