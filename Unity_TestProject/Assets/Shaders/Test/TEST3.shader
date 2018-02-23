Shader "Test/Particle System Magnet"
{
	Properties
	{
		_TintColor ("Tint Color (RGB)  Trans (A)" , Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Base (RGB)  Trans (A)", 2D) = "white" {}
		_Offset ("Intensity", Float) = 1
		_Range ("Range", Float) = 1
		_Power ("Spread", Float) = 1
		_Mag ("Magnet Location", Vector) = (0,0,0,0)
	}

	SubShader
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		LOD 100

		Pass
		{  
			Blend SrcAlpha One
			Zwrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 2.0
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			half4 _TintColor, _MainTex_ST, _Mag;
			half _Offset, _Range, _Power;

			struct appdata
			{
			    half4 vertex : POSITION;
			    half4 texcoord : TEXCOORD0;
			    half custom : TEXCOORD1;
			    half4 color : COLOR;
			};

			struct v2f
			{
			    half4 pos : SV_POSITION;
			    half2 uv : TEXCOORD0;
			    half4 color : COLOR;
			    half1 test : TEXCOORD1;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				half3 pPos = half3(v.texcoord.zw, v.custom.x);
				half3 magPos = _Mag.xyz;

				half3 target = (pPos - magPos) * _Offset;

				half temp = distance(pPos, magPos)*_Range;
				temp = pow(temp, _Power);

				half3 offset = lerp (target, half3(0,0,0), clamp(temp,0,1));

				v.vertex.xyz += offset;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.color = v.color;
				o.test = clamp(temp,0,1);
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				half4 tex = tex2D(_MainTex, i.uv);
				//tex *= lerp(i.color, _TintColor, i.test);
				return tex;
			}
			ENDCG
		}
	}
}