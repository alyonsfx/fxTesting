Shader "Test/Vert Offset"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_test ("Test", float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" }
		LOD 100
		cull off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _test;
			
			v2f vert (appdata v)
			{
				v2f o;
				float3 bitangent = cross( v.normal, v.tangent.xyz ) * v.tangent.w;
				bitangent *= v.uv.y*2-1;
				o.vertex = UnityObjectToClipPos(v.vertex + bitangent * _test);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv).xxxx;
				return col;
			}
			ENDCG
		}
	}
}
