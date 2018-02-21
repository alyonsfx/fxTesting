Shader "Mobile/Particles/Slide"
{
	Properties
	{
		_MainTex("Particle Texture (Greyscale)", 2D) = "white" { }
		_Offset("Offset", float) = 0
		_WhitePoint("Highlight", float) = 1
		_Range("Range", float) = 1
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
			#pragma fragmentoption ARB_precision_hint_fastest
			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;

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
			
			float4 _MainTex_ST;
			float _WhitePoint, _Range, _Offset;

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
				tex = frac(tex+_Offset);
				float4 mask = float(0).xxxx;
				_Range *= 0.5;
				float2 minmax = float2(_WhitePoint - _Range, _WhitePoint + _Range);
				mask.x = ceil(tex.x - minmax.x);
				mask.y = 1-floor(tex.x + minmax.y);
				mask.z = lerp(mask.x,mask.y,tex.x);
				//col.a = tex.a;
				//col *= i.color * tex.a;
				//saturate(col);
				//return col;
				return mask.z;
			}
			ENDCG
		}
	}
	FallBack "Mobile/Particles/Additive"
}