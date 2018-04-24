Shader "Character/Vertex Simple"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _SpecPower ("Specular Intensity", float) = 1
		_SpecRoll ("Specular Rolloff", float) = 2.0
        _GlowIntensity ("Glow Intensity", Range(0.0, 1.0)) = 1
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

            // compile shader into multiple variants, with and without shadows
            // (we don't care about any lightmaps yet, so skip these variants)
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap
            // shadow helper functions and macros
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            half _SpecPower, _SpecRoll, _GlowIntensity;

            struct appdata
            {
                float4 vertex : POSITION;
                half3 normal : NORMAL;
                half2 texcoord0 : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
                SHADOW_COORDS(1) // put shadows data into TEXCOORD1
                half3 diff : COLOR0;
                half3 amb : COLOR1;
                half3 spec : COLOR2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord0;
                // get vertex normal in world space
                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                // dot product between normal and light direction for
                // standard diffuse (Lambert) lighting
                half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                // factor in the light color
                o.diff = nl * _LightColor0;
                // Light probe info
                o.amb = ShadeSH9(half4(worldNormal,1));
                TRANSFER_SHADOW(o);

                fixed3 worldV = normalize(-WorldSpaceViewDir(v.vertex));
                fixed3 refl = reflect(worldV, worldNormal);
                fixed3 worldLightDir = _WorldSpaceLightPos0;
                //spec = dot(worldLightDir, refl);
                fixed3 um = saturate(dot(worldLightDir, refl));

                o.spec = pow(um, _SpecRoll);

                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                //c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten;
                half shadow = SHADOW_ATTENUATION(i);
                half4 tex = tex2D(_MainTex, i.uv);
                half3 lighting = (i.diff + i.diff * i.spec * tex.a) *  shadow + i.amb;
                half3 col = tex * lighting;
                //Glow
                //col = lerp(col,tex,tex.a * _GlowIntensity);
                //UNITY_OPAQUE_ALPHA(col.a);
                return half4(col,1);
            }
            ENDCG
        }
        UsePass "Hidden/Shadows/SHADE"
    }
}
