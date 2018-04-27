Shader "Character/Frag Bump"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
        _Shininess ("Shininess", Range(0.03, 1)) = 0.078125
        [NoScaleOffset] _BumpMap ("Normalmap", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Range (0, 1)) = 1
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityStandardBRDF.cginc"
            #include "UnityStandardUtils.cginc"
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap noforwardadd
            #include "AutoLight.cginc"

            sampler2D _MainTex, _BumpMap;
            half _Shininess, _BumpScale;

            struct appdata
            {
                float4 vertex : POSITION;
                half3 normal : NORMAL;
                half4 tangent : TANGENT;
                half2 texcoord0 : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
                half3 normal : TEXCOORD1;
                half3 tangent : TEXCOORD2;
                half3 binormal : TEXCOORD3;
                half3 worldPos : TEXCOORD4;
                SHADOW_COORDS(5) // put shadows data into TEXCOORD1
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.texcoord0;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = half4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
                o.binormal = cross(v.normal, v.tangent.xyz) * (v.tangent.w * unity_WorldTransformParams.w);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                TRANSFER_SHADOW(o);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 albedo = tex2D(_MainTex, i.uv);

                half3 bump = UnpackScaleNormal(tex2D(_BumpMap, i.uv), _BumpScale);
                bump = normalize(bump.x * i.tangent + bump.y * i.binormal + bump.z * i.normal);
                //i.worldPos = bump;
                //i.worldNorm = normalize(i.worldNorm);
                half3 lightDir = _WorldSpaceLightPos0.xyz;
                half3 lightColor = _LightColor0.rgb;
                half3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

                half diff = max (0, dot (bump, lightDir));
                half3 halfVector = normalize(lightDir + viewDir);
                half nh = max (0, dot (bump, halfVector));
                half spec = pow (nh, _Shininess*128.0) * albedo.a;
                half3 amb = ShadeSH9(half4(bump,1)) * albedo.rgb;
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