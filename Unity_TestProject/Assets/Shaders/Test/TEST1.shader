Shader "Test/Diffuse + Glow v1"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		[NoScaleOffset] _EmissionMap ("Glow (RGB)", 2D) = "black" {}
		_Glow ("Glow Intensity", Range (0,1)) = 0
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry" }
		LOD 100

		Pass { 
			Tags {"LightMode" = "ForwardBase"}
			Lighting On

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			sampler2D _MainTex, _EmissionMap;
			float4 _MainTex_ST;
			fixed _Glow;


			struct appdata_t
			{
				float4 vertex : POSITION;
				half3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv0 : TEXCOORD0;
				fixed4 lightDirection : TEXCOORD1;
				fixed3 viewDirection : TEXCOORD2;
				fixed3 normalWorld : TEXCOORD3;
				LIGHTING_COORDS(4,5)
			};

			v2f vert (appdata_t v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv0 = TRANSFORM_TEX(v.texcoord, _MainTex);
				half4 posWorld = mul( unity_ObjectToWorld, v.vertex );
				o.normalWorld = normalize( mul(half4(v.normal, 0.0), unity_WorldToObject).xyz );
				o.viewDirection = normalize(_WorldSpaceCameraPos.xyz - posWorld.xyz);

				TRANSFER_VERTEX_TO_FRAGMENT(o);

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 col = tex2D(_MainTex, i.uv0).rgb;
				fixed NdotL = dot(i.normalWorld, i.lightDirection);
				half atten = LIGHT_ATTENUATION(i);
				col *= atten;

				fixed3 glow = tex2D(_EmissionMap, i.uv0).rgb * clamp(_Glow, 0,1);

				return fixed4(col + glow, 1.0);
			}

		ENDCG
		}
	}
	FallBack "Diffuse"
}