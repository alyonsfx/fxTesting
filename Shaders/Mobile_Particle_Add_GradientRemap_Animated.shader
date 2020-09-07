Shader "Particle/Gradient Mapped (Animated)"
{
	Properties {
		_TintColor ("Tint Color", Color) = (1,1,1,1)
		_ShapesTex ("Shapes Texture", 2D) = "white" {}
		_GradientMap ("Gradient Map", 2D) = "white" {}
		_GradientAlphaMap ("Gradient Alpha Map", 2D) = "white" {}
		_Rows ("Ramp Rows", Float) = 4
	}

	Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend SrcAlpha OneMinusSrcAlpha
	Cull Off
	Lighting Off
	ZWrite Off

	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_particles
			
			#include "UnityCG.cginc"

			sampler2D _ShapesTex, _GradientMap, _GradientAlphaMap;
			half4 _TintColor, _ShapesTex_ST;
			half _Rows;
			
			struct appdata_t {
				half4 vertex : POSITION;
				half4 color : COLOR;
				half2 texcoord : TEXCOORD0;
			};

			struct v2f {
				half4 vertex : SV_POSITION;
				half4 color : COLOR;
				half2 texcoord : TEXCOORD0;
				half rampTiling : TEXCOORD2;
				half rampOffset : TEXCOORD3;
				half2 rampRowOffset : TEXCOORD4;
			};

			v2f vert (appdata_t v)
			{
				v2f o;
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;

				o.texcoord.xy = TRANSFORM_TEX(v.texcoord.xy, _ShapesTex);

				o.rampTiling = 1/_Rows; //just makes it easier to just put in the rows of the ramp textures
				o.rampOffset = o.rampTiling * 0.5;

				o.rampRowOffset.x = (floor(v.color.r * _Rows) * o.rampTiling ) +o.rampOffset;
				o.rampRowOffset.y = 1-(floor(v.color.a * _Rows) * o.rampTiling ) +o.rampOffset; //1- for reverting alpha input, makes more sense when setting up the gradient in the PS

				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{	
				half4 shapeTex = tex2D(_ShapesTex, i.texcoord.xy);

				//x is the current value of the pixel on the shapes texture
				//y is the current ramp texture row, depending on the red color assigned in the PS
				half2 rampColorUV;
				rampColorUV.x = shapeTex.r;
				rampColorUV.y = i.rampRowOffset.x;
				rampColorUV = saturate(rampColorUV);

				//remap the colors once for current row and once for the next and then lerp between them
				half3 reColored1 = tex2D(_GradientMap, rampColorUV);
				half3 reColored2 = tex2D(_GradientMap, half2(rampColorUV.x, rampColorUV.y + i.rampTiling));

				half3 reColorLerp = lerp(reColored1, reColored2, frac(i.color.r / i.rampTiling)); 
				

				half2 rampAlphaUV;
				rampAlphaUV.x = shapeTex.a;
				rampAlphaUV.y = i.rampRowOffset.y;
				rampAlphaUV = saturate(rampAlphaUV);

				half reAlpha1 = tex2D(_GradientAlphaMap, rampAlphaUV).r;
				half reAlpha2 = tex2D(_GradientAlphaMap, half2(rampAlphaUV.x, rampAlphaUV.y + i.rampTiling)).r;

				half reAlphaLerp = lerp(reAlpha1.r, reAlpha2.r, 1-frac(i.color.a / i.rampTiling)); 


				half4 col;
				col.rgb = reColorLerp * _TintColor.rgb;
				col.a = reAlphaLerp * _TintColor.a;

				return col;
			}
			ENDCG 
		}
	}	
}
}