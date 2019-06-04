Shader "Character/Surface"
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
		Tags { "RenderType" = "Opaque" }
		LOD 250
		
		CGPROGRAM
		
		#include "../CustomLighting.cginc"
		#pragma surface surf Custom exclude_path:deferred exclude_path:prepass nolightmap noforwardadd halfasview interpolateview addshadow
		
		sampler2D _MainTex, _BumpMap;
		half _Shininess, _BumpScale;
		half4 _GlowColor;
		
		struct Input
		{
			half2 uv_MainTex;
		};
		
		void surf(Input IN, inout SurfaceOutputCustom o)
		{
			half4 tex = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = tex.rgb;
			o.Normal = UnpackScaleNormal (tex2D(_BumpMap, IN.uv_MainTex), _BumpScale);
			o.Emission = 0;
			o.Specular = _Shininess;
			o.Gloss = tex.a;
			o.Alpha = 1;
			o.Occlusion = 1;
		}
		ENDCG
		
	}
}
