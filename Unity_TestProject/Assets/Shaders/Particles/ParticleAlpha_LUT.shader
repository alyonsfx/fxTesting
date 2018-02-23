// Their are 2 dissovel methods
Shader "Custom/Particles/Alpha Blended (Color Remap)"
{
	Properties
	{
		_MainTex ("Particle Mask (R)", 2D) = "white" {}
        [NoScaleOffset] _RampTex("Color Remap Texture", 2D) = "black" { }
        _Erode ("Alpha Erossion", Range(0.00,1.00)) = 0
	}

	Category
	{
		SubShader
		{
			Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }

			Pass
			{
				Blend SrcAlpha OneMinusSrcAlpha
				Cull Off
				ZWrite Off

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma target 2.0

				#include "UnityCG.cginc"
                #include "../Family.cginc"

				half4 _MainTex_ST;
				sampler2D _MainTex, _RampTex;
                half _Erode;
				
				struct appdata
				{
				    float4 vertex : POSITION;
				    half4 texcoord0 : TEXCOORD0;
				    half4 color : COLOR;
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					half3 uv : TEXCOORD0;
					half4 color : COLOR;
				};

				v2f vert (appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.color = v.color;
					o.uv.xy = TRANSFORM_TEX(v.texcoord0.xy,_MainTex);
                    o.uv.z = (1-_Erode) * (1-v.texcoord0.z);
					return o;
				}
				
				half4 frag (v2f i) : SV_Target
				{
                    //Eronsion eats into remaped colors
                    //half tex = tex2D(_MainTex, i.uv.xy).r;
                    //half3 col = tex2D(_RampTex, half2(tex,0)) * i.color;
                    //half alpha = erode(tex, i.uv.z);
					//return half4(col,alpha);

                    //Maintains the color ramp
                    half tex = erode(tex2D(_MainTex, i.uv.xy).r, i.uv.z);
                    half3 col = tex2D(_RampTex, half2(tex,0)) * i.color;
                    return half4(col,tex);
				}
				ENDCG 
			}
		}	
	}
}