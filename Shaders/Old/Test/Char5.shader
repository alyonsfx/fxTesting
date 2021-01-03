Shader "Test/Here we go"
{
    Properties {
        _Color("Base Color", Color) = (0.5,0.5,0.5,1)
        _MainTex("Base texture", 2D) = "white" {}
        _BumpMap("Normal Map", 2D) = "bump" {}
        _Spec("Specular", float) = 1
        _Gloss("Gloss", float) = 1
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            //#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            #include "AutoLight.cginc"

            sampler2D _MainTex, _BumpMap;
            half4 _Color;
            half _Spec, _Gloss;

            struct appdata
         {
             float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
         };

            struct v2f
            {
                // ---- Bumped reflection v2f
                // float3 worldPos : TEXCOORD0;
                // half3 tspace0 : TEXCOORD1;
                // half3 tspace1 : TEXCOORD2;
                // half3 tspace2 : TEXCOORD3;
                // float2 uv : TEXCOORD4;
                // float4 pos : SV_POSITION;

                // ---- Diffuse v2f
                // float2 uv : TEXCOORD0;
                // SHADOW_COORDS(1) // put shadows data into TEXCOORD1
                // fixed3 diff : COLOR0;
                // fixed3 ambient : COLOR1;
                // float4 pos : SV_POSITION;

                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
                //SHADOW_COORDS(1) //TEXCOORD1
                float3 worldPos : TEXCOORD2;
                half3 tspace0 : TEXCOORD3;
                half3 tspace1 : TEXCOORD4;
                half3 tspace2 : TEXCOORD5;
                half3 worldNorm : TEXCOORD6;
                // Gonna need some vert color too :(
                // Maybe a second UV set?
            };





            v2f vert (appdata v)
            {
                // Bumped reflection v2f
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNorm = UnityObjectToWorldNormal(v.normal);
                half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
                half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                half3 wBitangent = cross(o.worldNorm, wTangent) * tangentSign;
                o.tspace0 = half3(wTangent.x, wBitangent.x, o.worldNorm.x);
                o.tspace1 = half3(wTangent.y, wBitangent.y, o.worldNorm.y);
                o.tspace2 = half3(wTangent.z, wBitangent.z, o.worldNorm.z);
                //return o;

                //Diffuse only v2f
                // v2f o;
                // o.pos = UnityObjectToClipPos(v.vertex);
                // o.uv = v.texcoord;
                // half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                // half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                // o.diff = nl * _LightColor0.rgb;
                // o.ambient = ShadeSH9(half4(o.worldNorm,1));
                // // compute shadows data
                // TRANSFER_SHADOW(o)
                // return o;

                // v2f o;
                // o.pos = UnityObjectToClipPos(v.vertex);
                // o.uv = v.uv;
                return o;
            }
        
            fixed4 frag (v2f i) : SV_Target
            {
                // Decode and convert reflections to normal map
                half3 tnormal = UnpackNormal(tex2D(_BumpMap, i.uv));
                half3 worldNormal;
                worldNormal.x = dot(i.tspace0, tnormal);
                worldNormal.y = dot(i.tspace1, tnormal);
                worldNormal.z = dot(i.tspace2, tnormal);
                half3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                half3 worldRefl = reflect(-worldViewDir, worldNormal);
                // half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldRefl);
                // half3 skyColor = DecodeHDR (skyData, unity_SpecCube0_HDR);                
                // fixed4 c = 0;
                // c.rgb = skyColor;

                // Simple Blinn Phong Lighting
                // fixed diff = max (0, dot (s.Normal, lightDir));
                // fixed nh = max (0, dot (s.Normal, halfDir));
                // fixed spec = pow (nh, s.Specular*128) * s.Gloss;


                half4 mainTex = tex2D(_MainTex, i.uv);

                // Bad Normal mapped reflection
                // modulate sky color with the base texture, and the occlusion map
                // fixed3 baseColor = tex2D(_MainTex, i.uv).rgb;
                // fixed occlusion = tex2D(_OcclusionMap, i.uv).r;
                // c.rgb *= baseColor;
                // c.rgb *= occlusion;

                // Specular Math
                // fixed4 c;
                // c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten;
                // UNITY_OPAQUE_ALPHA(c.a);
                // return c;

                //Simple Lambert
                // fixed4 col = tex2D(_MainTex, i.uv);
                // fixed shadow = SHADOW_ATTENUATION(i); // compute shadow attenuation (1.0 = fully lit, 0.0 = fully shadowed)
                // fixed3 lighting = i.diff * shadow + i.ambient; // darken light's illumination with shadow, keep ambient intact
                // col.rgb *= lighting;
                //return col;

                half nl = max(0, dot(worldRefl, _WorldSpaceLightPos0.xyz));
                half3 diffuse = nl * _LightColor0.rgb;
                half3 lighting = ShadeSH9(half4(worldRefl,1));
                //half3 spec = pow(spec, mainTex.a) * _Gloss;

                lighting = mainTex.rgb * diffuse;// * lighting;// + spec * lighting;

                return half4(lighting* 2,1);
            }
            ENDCG
        }
    }
}