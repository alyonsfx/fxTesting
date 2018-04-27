Shader "Character/Frag Bump"
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
				SHADOW_COORDS(1) // put shadows data into TEXCOORD1
				half3 worldNorm: TEXCOORD2;
				half3 worldPos: TEXCOORD3;
			};
			
			v2f vert(appdata v)
			{
				v2f o;
				o.uv = v.texcoord0;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNorm = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				TRANSFER_SHADOW(o);
				return o;
			}
			
			half4 frag(v2f i): SV_Target
			{
				half4 albedo = tex2D(_MainTex, i.uv);
				
				i.worldNorm = normalize(i.worldNorm);
				half3 lightDir = _WorldSpaceLightPos0.xyz;
				half3 lightColor = _LightColor0.rgb;
				half3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				
				half diff = max(0, dot(i.worldNorm, lightDir));
				half3 halfVector = normalize(lightDir + viewDir);
				half nh = max(0, dot(i.worldNorm, halfVector));
				half spec = pow(nh, _Shininess * 128.0) * albedo.a;
				half3 amb = half3(0, 0, 0);
				amb = ShadeSHPerPixel(i.worldNorm, amb, i.worldPos) * albedo.rgb;
				half shadow = SHADOW_ATTENUATION(i);
				half3 diffuse = lightColor * diff * albedo.rgb;
				half3 specular = lightColor * spec;
				
				half3 col = (diffuse + specular) * shadow + amb;
				return float4(col, 1);
			}
			ENDCG
			
		}
		UsePass "Hidden/Shadows/SHADE"
	}
}