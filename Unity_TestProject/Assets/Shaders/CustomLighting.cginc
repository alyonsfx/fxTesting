#ifndef MYLIGHTING_INCLUDED
	#define MYLIGHTING_INCLUDED
	
	//#include "Lighting.cginc"
	
	void mylighting(half3 normal, half3 lightDir, half3 worldPos, half shine, inout half diff, inout half spec)
	{
		half3 viewDir = normalize(_WorldSpaceCameraPos - worldPos);
		
		diff = max(0, dot(normal, lightDir));
		half3 halfVector = normalize(lightDir + viewDir);
		half nh = max(0, dot(normal, halfVector));
		spec = pow(nh, shine * 128.0);
	}
	
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
	
	inline half4 LightingCustom(SurfaceOutputCustom s, half3 lightDir, half3 halfDir, half atten)
	{
		half d = max(0, dot(s.Normal, lightDir));
		half nh = max(0, dot(s.Normal, halfDir));
		half spec = pow(nh, s.Specular * 128) * s.Gloss;
		half3 diffuse = _LightColor0.rgb * d * s.Albedo;
		half3 specular = _LightColor0.rgb * spec;
		fixed4 c;
		c.rgb = (diffuse + specular) * atten * s.Occlusion;
		UNITY_OPAQUE_ALPHA(c.a);
		return c;
	}
	
#endif