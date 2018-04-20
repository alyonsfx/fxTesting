// Single pass light probe shader
Shader "Rocket Boy/Character/Menu"
{
	Properties
	{
		_MainTex("Texture (A = Emissive)", 2D) = "white" {}
		_ReflectMask("Reflection Mask", 2D) = "grey" {}
		_SpecRoll("Specular Rolloff", Range(0.01, 1.0)) = 0.1
		_ReflectIntensity("Reflection Intensity", Range(0.0, 1.0)) = 1.0
		_ReflectMap("Reflection Cubemap", Cube) = "_Skybox" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "RenderEffect"="Glow"}

		CGPROGRAM
		#pragma surface surf BlinnPhong

		sampler2D _MainTex, _ReflectMask;
		samplerCUBE _ReflectMap;
		fixed4 _Color;
		half _SpecRoll, _ReflectIntensity;

		struct Input
		{
			float2 uv_MainTex;
			float3 worldRefl;
		};

		void surf (Input IN, inout SurfaceOutput o)
		{
			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
			fixed4 spec = tex2D(_ReflectMask, IN.uv_MainTex);
			fixed4 reflcol = texCUBE (_ReflectMap, IN.worldRefl) * _ReflectIntensity;
			reflcol.rgb *= spec.rgb;
			
			o.Albedo = tex.rgb;
			o.Gloss = _SpecRoll;
			o.Specular = spec.r * 0.3 + spec.g * 0.59 + spec.b * 0.11;
			
			fixed3 glow = tex.rgb * tex.a; 
			o.Emission = saturate(glow + reflcol.rgb);
			o.Alpha = 1;
		}
	ENDCG
	}
	FallBack "Legacy Shaders/Reflective/VertexLit"
}