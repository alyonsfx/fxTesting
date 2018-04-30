Shader "Character/Surface"
{
	Properties
	{
		_MainTex ("Base (RGB) Glow (A)", 2D) = "white" { }
		_GlowColor ("Glow Color (RGB) Intensity (A)", Color) = (1, 1, 1, 0)
		[NoScaleOffset] _BumpMap ("Normalmap", 2D) = "bump" { }
		_SpecTex ("Spec (RGB) Occ (A)", 2D) = "white" { }
		_Shininess ("Shininess", Range(0.03, 1)) = 0.078125
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 250
		
		CGPROGRAM
		
		#include "../CustomLighting.cginc"
		#pragma surface surf Custom exclude_path:deferred exclude_path:prepass nolightmap noforwardadd halfasview interpolateview addshadow
		
		sampler2D _MainTex, _SpecTex, _BumpMap;
		half _Shininess;
		half4 _GlowColor;
		
		struct Input
		{
			half2 uv_MainTex;
		};
		
		void surf(Input IN, inout SurfaceOutputCustom o)
		{
			half4 tex = tex2D(_MainTex, IN.uv_MainTex);
			half4 spec = tex2D(_SpecTex, IN.uv_MainTex);
			o.Albedo = tex.rgb;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
			o.Emission = _GlowColor.rgb * _GlowColor.a * tex.a;
			o.Specular = _Shininess;
			o.Gloss = spec.rgb;
			o.Alpha = 1;
			o.Occlusion = spec.a;
		}
		ENDCG
		
	}
}
