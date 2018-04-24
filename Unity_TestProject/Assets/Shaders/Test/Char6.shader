Shader "Test/Per Vert Lighting With Normal"
{
    Properties
    {
        _NormalTex("Normal Map", 2D) = "bump"
    }

    SubShader
    {
        Pass
        {
            Tags{ "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase nolightmap nodynlightmap nodirlightmap novertexlight
            #include "AutoLight.cginc"

            struct appdata
            {
                float3 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                SHADOW_COORDS(1)
                float3 tangentSpaceLight : TEXCOORD2;
                //fixed3 diff : COLOR0;
                float3 ambient : COLOR1;
            };

            sampler2D _NormalTex;
            float4 _NormalTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _NormalTex);

                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 tangent = UnityObjectToWorldNormal(v.tangent);
                float3 bitangent = cross(tangent, worldNormal);

                o.tangentSpaceLight = float3(dot(tangent, _WorldSpaceLightPos0), dot(bitangent, _WorldSpaceLightPos0), dot(worldNormal, _WorldSpaceLightPos0));
                o.tangentSpaceLight *= _LightColor0.rgb;

                o.ambient = ShadeSH9(half4(worldNormal,1));

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 tangentNormal = tex2D(_NormalTex, i.uv) * 2 - 1;
                fixed shadow = SHADOW_ATTENUATION(i);
                fixed4 col = dot(tangentNormal, i.tangentSpaceLight) * shadow;
                col.rgb  += i.ambient;
                return fixed4(col.rgb,1);
            }
            ENDCG
        }
        Pass
        {
            Tags { "LightMode" = "ShadowCaster" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct appdata 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert( appdata v )
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag( v2f i ) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
}