Shader "Character/Vertex Simple"
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
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap noforwardadd
			#include "AutoLight.cginc"
			#include "../CustomLighting.cginc"
			
			sampler2D _MainTex;
			half  _Shininess;
			
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
				half diff: TEXCOORD2;
				half spec: TEXCOORD3;
				half3 amb: COLOR0;
			};
			
			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord0;
				//half3 lightDir = _WorldSpaceLightPos0.xyz;
				half3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				half3 worldPos = mul(unity_ObjectToWorld, v.vertex);
				//half3 viewDir = normalize(_WorldSpaceCameraPos - worldPos);
				
				//o.diff = max(0, dot(worldNormal, lightDir));
				//half3 halfVector = normalize(lightDir + viewDir);
				//half nh = max(0, dot(worldNormal, halfVector));
				//o.spec = pow(nh, _Shininess * 128.0);
				mylighting(worldNormal, _WorldSpaceLightPos0.xyz, worldPos, _Shininess, o.diff, o.spec);
				
				o.amb = ShadeSH9(half4(worldNormal, 1));
				TRANSFER_SHADOW(o);
				return o;
			}
			
			half4 frag(v2f i): SV_Target
			{
				half4 tex = tex2D(_MainTex, i.uv);
				
				half3 lightColor = _LightColor0.rgb;
				half3 diffuse = tex.rgb * i.diff * lightColor;
				half3 specular = i.spec * tex.a * lightColor;
				half shadow = SHADOW_ATTENUATION(i);
				
				half3 col = (diffuse + specular) * shadow + i.amb * tex.rgb;
				return half4(col, 1);
			}
			ENDCG
			
		}
		UsePass "Hidden/Shadows/SHADE"
	}
}
