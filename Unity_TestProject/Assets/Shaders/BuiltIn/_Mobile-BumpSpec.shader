// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)
// Simplified Bumped Specular shader. Differences from regular Bumped Specular one:
// - no Main Color nor Specular Color
// - specular lighting directions are approximated per vertex
// - writes zero to alpha channel
// - Normalmap uses Tiling/Offset of the Base texture
// - no Deferred Lighting support
// - no Lightmap support
// - fully supports only 1 directional light. Other lights can affect it, but it will be per-vertex/SH.

Shader "Char/Unity Mobile Bumped Specular"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
        _Shininess ("Shininess", Range (0.03, 1)) = 0.078125
        [NoScaleOffset] _BumpMap ("Normalmap", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Range (0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 250

        CGPROGRAM
        #include "Lighting.cginc"
        #pragma surface surf MobileBlinnPhong exclude_path:prepass nolightmap noforwardadd halfasview interpolateview

        inline half4 LightingMobileBlinnPhong (SurfaceOutput s, half3 lightDir, half3 halfDir, half atten)
        {
            half diff = max (0, dot (s.Normal, lightDir));
            half nh = max (0, dot (s.Normal, halfDir));
            half spec = pow (nh, s.Specular*128) * s.Gloss;
            half3 diffuse = _LightColor0.rgb * diff * s.Albedo;
            half3 specular = _LightColor0.rgb * spec;
            fixed4 c;
            c.rgb = (diffuse + specular) * atten;
            UNITY_OPAQUE_ALPHA(c.a);
            return c;
        }

        sampler2D _MainTex, _BumpMap;
        half _Shininess, _BumpScale;

        struct Input
        {
            half2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            half4 tex = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = tex.rgb;
            o.Gloss = tex.a;
            o.Alpha = 1;
            o.Specular = _Shininess;
            o.Normal = UnpackScaleNormal (tex2D(_BumpMap, IN.uv_MainTex), _BumpScale);
        }
        ENDCG
        UsePass "Hidden/Shadows/SHADE"
    }
}