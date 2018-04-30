Shader "Character/Frag Simple"
{
	Properties
	{
		[NoScaleOffset] _MainTex ("Base (RGB) Gloss (A)", 2D) = "white" { }
		_Shininess ("Shininess", Range(0.03, 1)) = 0.078125
	}
	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityStandardBRDF.cginc"
			#include "UnityStandardUtils.cginc"
			#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap noforwardadd
			#include "AutoLight.cginc"
			#include "../CustomLighting.cginc"
			
			sampler2D _MainTex;
			half _Shininess;
			
			struct appdata
			{
				float4 vertex: POSITION;
				half3 normal: NORMAL;
				half2 texcoord0: TEXCOORD0;
			};
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				half2 uv: TEXCOORD0;
				half3 normal: TEXCOORD1;
				half3 worldPos: TEXCOORD2;
				SHADOW_COORDS(3)
			};
			
			v2f vert(appdata v)
			{
				v2f o;
				o.uv = v.texcoord0;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				TRANSFER_SHADOW(o);
				return o;
			}
			
			half4 frag(v2f i): SV_Target
			{
				half4 albedo = tex2D(_MainTex, i.uv);
				
				half3 norm = normalize(i.normal);
				// half3 lightDir = _WorldSpaceLightPos0.xyz;
				half3 lightColor = _LightColor0.rgb;
				// half3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				
				// half diff = max(0, dot(norm, lightDir));
				// half3 halfVector = normalize(lightDir + viewDir);
				// half nh = max(0, dot(norm, halfVector));
				// half spec = pow(nh, _Shininess * 128.0);
				
				half diff;
				half spec;
				mylighting(norm, _WorldSpaceLightPos0.xyz, i.worldPos, _Shininess, diff, spec);
				
				half3 amb = ShadeSH9(half4(norm, 1)) * albedo.rgb;
				half shadow = SHADOW_ATTENUATION(i);
				
				half3 diffuse = lightColor * diff * albedo.rgb;
				half3 specular = lightColor * spec * albedo.a;
				
				half3 col = (diffuse + specular) * shadow + amb;
				return float4(col, 1);
			}
			ENDCG
			
		}
		UsePass "Hidden/Shadows/SHADE"
	}
}