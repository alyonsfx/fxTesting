// No realtime light
// Multiplies light probe data to fake shading
// Addes specular highlights per vert
// Vertex Color: Red = Jitter Blue = Alpha Green = Vertex Tint
Shader "Rocket Boy/Character/Probe Lighting"
{
	Properties
	{
		_Tint ("Color Tint (Additive)", Color) = (0, 0, 0, 1)
		_Desat ("Saturation", Range(0.0, 1.0)) = 1.0
		[NoScaleOffset] _MainTex ("Diffuse (RGB) Emissive (A)", 2D) = "grey" { }
		_SpecPower ("Specular Intensity", float) = 1
		_SpecRoll ("Specular Rolloff", float) = 2.0
		[NoScaleOffset] _SpecTex ("Specular (RGB) Lighting Mask (A)", 2D) = "white" { }
		_DetailPower ("Detail Intensity", Range(0.0, 1.0)) = 0
		_DetailTex ("Detail (RGB) Mask (A)", 2D) = "white" { }
		_GlowIntensity ("Glow Intensity", Range(0.0, 1.0)) = 1
		_VertTint ("Vertex Tint", Color) = (1, 1, 1, 1)
	}
	
	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
		Lighting Off
		Pass
		{
			Name "BASE"
			Tags { "LightMode" = "ForwardBase" }
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			
			#pragma fragment frag
			#pragma vertex vert
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 2.0
			
			#include "UnityCG.cginc"
			#include "RocketBoy.cginc"
			
			fixed4 _Tint, _VertTint;
			fixed _Desat, _SpecPower, _SpecRoll, _DetailPower, _GlowIntensity;
			uniform sampler2D _MainTex;
			uniform sampler2D _SpecTex;
			uniform sampler2D _DetailTex;
			
			struct appdata
			{
				fixed4 vertex: POSITION;
				fixed4 texcoord: TEXCOORD0;
				fixed3 normal: NORMAL;
				fixed4 color: COLOR;
			};
			
			struct v2f
			{
				fixed4 pos: SV_POSITION;
				fixed2 uv: TEXCOORD0;
				fixed3 diffuse: TEXCOORD1;
				fixed3 spec: TEXCOORD2;
				fixed3 vertexTint: TEXCOORD3;
			};
			
			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				// lighting
				diffuseSpec(v.normal, v.vertex, _SpecRoll, _SpecPower, o.diffuse, o.spec);
				// vertex tinting
				o.vertexTint = v.color.xxx;
				return o;
			}
			
			fixed4 frag(v2f i): SV_Target
			{
				fixed4 main = desaturate(tex2D(_MainTex, i.uv), 1 - _Desat);
				fixed4 spec = desaturate(tex2D(_SpecTex, i.uv), 1 - _Desat);
				//Detail Overlay
				fixed4 detail = tex2D(_DetailTex, i.uv);
				detail.xyz = lerp(main, main * detail, _DetailPower);
				main.xyz = lerp(main, detail, detail.a);
				// vertex tinting
				main.xyz *= lerp(fixed3(1, 1, 1), _VertTint, i.vertexTint);
				// diffuse shading
				fixed4 c = main;
				c.xyz = main.xyz * lerp(fixed3(1, 1, 1), i.diffuse, 1 - spec.aaa);
				// fake specular highlights
				c.xyz += (i.spec * spec);
				// glow
				c.xyz = lerp(c, main, main.a * _GlowIntensity);
				// overall tint
				c.xyz += _Tint;
				c.a = _Tint.a;
				return c;
			}
			ENDCG
			
		}
	}
	//Fallback "Mobile/VertexLit"
}