// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Char/Unity Legacy VertexLit" 
{
    Properties {
        _Color ("Main Color", Color) = (1,1,1,1)
        _SpecColor ("Spec Color", Color) = (1,1,1,1)
        _Emission ("Emissive Color", Color) = (0,0,0,0)
        _Shininess ("Shininess", Range (0.01, 1)) = 0.7
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        // Non-lightmapped
        Pass
        {
            Tags { "LightMode" = "Vertex" }

            Material
            {
                Diffuse [_Color]
                Ambient [_Color]
                Shininess [_Shininess]
                Specular [_SpecColor]
                Emission [_Emission]
            }

            Lighting On
            SeparateSpecular On
            SetTexture [_MainTex]
            {
                constantColor (1,1,1,1)
                Combine texture * primary DOUBLE, constant // UNITY_OPAQUE_ALPHA_FFP
            }
        }

        // Lightmapped
        Pass
        {
            Tags{ "LIGHTMODE" = "VertexLM" "RenderType" = "Opaque" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #include "UnityCG.cginc"

            float4 unity_Lightmap_ST;
            float4 _MainTex_ST;

            struct appdata
            {
                float3 pos : POSITION;
                float3 uv1 : TEXCOORD1;
                float3 uv0 : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata IN)
            {
                v2f o;

                o.uv0 = IN.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                o.uv1 = IN.uv1.xy * unity_Lightmap_ST.xy + unity_Lightmap_ST.zw;
                o.uv2 = IN.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                o.pos = UnityObjectToClipPos(IN.pos);
                return o;
            }

            sampler2D _MainTex;
            fixed4 _Color;

            fixed4 frag(v2f IN) : SV_Target
            {
                fixed4 col;

                fixed4 tex = UNITY_SAMPLE_TEX2D(unity_Lightmap, IN.uv0.xy);
                half4 bakedColor = half4(DecodeLightmap(tex), 1.0);

                col = bakedColor * _Color;

                tex = tex2D(_MainTex, IN.uv2.xy);
                col.rgb = tex.rgb * col.rgb;

                col.a = 1.0f;
                return col;
            }

            ENDCG
        }
        UsePass "Hidden/Shadows/SHADE"
    }
}
