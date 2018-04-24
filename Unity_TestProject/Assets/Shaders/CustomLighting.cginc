#include "Lighting.cginc"

struct SurfaceOutputCustom
{
    half3 Albedo;
    half3 Normal;
    half3 Emission;
    half Specular;
    half3 Gloss; //???
    half Alpha;
    half Occlusion;
};

inline half4 LightingCustom (SurfaceOutputCustom s, fixed3 lightDir, fixed3 halfDir, fixed atten)
{
    half diff = max (0, dot (s.Normal, lightDir)) * s.Occlusion;
    half nh = max (0, dot (s.Normal, halfDir));
    half3 spec = pow (nh, s.Specular*128) * s.Gloss * s.Occlusion;

    half4 c;
    c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten;
    UNITY_OPAQUE_ALPHA(c.a);
    return c;
}