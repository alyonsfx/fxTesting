Shader "Mobile/Particles/Additive (Gradient Remap)"
{
	Properties
	{
		_MainTex("Particle Texture (Greyscale)", 2D) = "white" { }
		[NoScaleOffset] _RampTex("Color Remap Texture", 2D) = "white" { }
	}
	
	SubShader
	{
		Pass
		{
			Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
			Blend SrcAlpha One
			ColorMask RGB
			Cull Off
			Lighting Off
			ZWrite Off
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#pragma multi_compile_particles
			#pragma fragmentoption ARB_precision_hint_fastest
			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex, _RampTex;

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
			};
			
			float4 _MainTex_ST, _RampTex_ST;

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = saturate(v.color);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 tex = tex2D(_MainTex, i.uv.xy);
				fixed4 col = tex2D(_RampTex, fixed2(tex.x,0.5));
				col.a = tex.a;
				col *= i.color * tex.a;
				saturate(col);
				return col;
			}
			ENDCG
		}
	}
	FallBack "Mobile/Particles/Additive"
}