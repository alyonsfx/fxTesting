// No realtime light
// Multiplies light probe data to fake shading
// Addes specular highlights per vert
// No Spec Map or Lighting Mask
// Vertex Color: Red = Jitter Blue = Alpha Green = Vertex Tint
Shader "Rocket Boy/Character/Probe Lighting (Fresnel Transparency)"
{
	Properties
	{
		_Tint("Color Tint (Additive)", Color) = (0, 0, 0, 1)
		_Desat("Saturation", Range(0.0, 1.0)) = 1.0
		[NoScaleOffset] _MainTex("Diffuse (RGB) Emissive (A)", 2D) = "grey" {}
		_SpecPower("Specular Intensity", float) = 1
		_SpecRoll("Specular Rolloff", float) = 2.0
		_FresnelWidth("Fresnel Width", Float) = 0.5
		_VertTint("Vertex Tint", Color) = (1, 1, 1, 1)
	}

	SubShader
	{
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
		Lighting Off
		Pass
		{
			Cull Back
			Name "BASE"
			Tags{ "LightMode" = "ForwardBase" }
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma fragment frag
			#pragma vertex vert
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 2.0
			
			#include "UnityCG.cginc"
			#include "RocketBoy.cginc"

			uniform fixed4 _Tint, _VertTint;
			uniform fixed _Desat, _SpecPower, _SpecRoll, _FresnelWidth;
			uniform sampler2D _MainTex;

			struct appdata
			{
				float4 vertex : POSITION;
				half4 normal : NORMAL;
				half4 texcoord : TEXCOORD0;
				half4 color : COLOR0;
			};
			struct v2f
			{
				float4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
				half3 diffuse : TEXCOORD1;
				half3 spec : TEXCOORD2;
				half3 vertexTintMask : TEXCOORD3;
				half fresnel : COLOR1;

			};
			v2f vert(appdata v)
			{
				v2f o;
				o.uv = v.texcoord;
				// lighting
				diffuseSpec(v.normal, v.vertex, _SpecRoll, _SpecPower, o.diffuse, o.spec);
				// fresnel
				o.fresnel = fresnelCharacter(v.vertex, v.normal, v.color, _FresnelWidth, half4(0,0,0,0)).a;
				// vertex tinting
				o.vertexTintMask = v.color.zzz;
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}
			half4 frag(v2f i) : SV_Target
			{
				half4 main = tex2D(_MainTex, i.uv);
				// vertex tinting
				main.xyz *= lerp(half3(1, 1, 1), _VertTint, i.vertexTintMask);
				// diffuse shading
				half4 c = main;
				//BROKEN
				//c.xyz = lerp(main.xyz, main.xyz * i.diffuse, _DiffusePower);
				// fake specular highlights
				c.xyz += i.spec;
				// glow
				c.xyz = lerp(c, main, main.a);
				// overall Tint
				c.xyz += _Tint;
				c.a = _Tint.a * i.fresnel;
				return c;
			}
			ENDCG
		}
	}
	Fallback "Mobile/VertexLit"
}