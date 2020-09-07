Shader "Custom/Particles/Alpha Blended (Scrolling Trail)"
{
	Properties
	{
		_MainTex ("Main Tex (R) Noise (G) Erode Mask (B)", 2D) = "white" {}
        _LUT ("Look Up Table (RGBA)", 2D) = "white" {}
		_Scroll ("Scroll Speed", Float) = -1
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

				sampler2D _MainTex, _LUT;
				half4 _MainTex_ST;
				half _Scroll;

                struct appdata
                {
                    float4 vertex : POSITION;
                    half2 texcoord0 : TEXCOORD0;
                    half4 color : COLOR;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    half4 uv0 : TEXCOORD0;
                    half4 color : COLOR;
                };

				v2f vert (appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.color = v.color;
					o.uv0.xy = v.texcoord0;
					half2 temp = TRANSFORM_TEX(v.texcoord0,_MainTex);
					o.uv0.zw = scrollUVs(temp, half2(_Scroll,0));
					return o;
				}
				
				half4 frag (v2f i) : SV_Target
				{
					half2 main = tex2D(_MainTex,i.uv0.xy).rb;
					half noise = tex2D(_MainTex, i.uv0.zw).g;
					half combined = main.x * noise;//lerp(main.x, main.x * noise, main.y);

					//half longMask = 
					// half main = tex2D(_MainTex, i.uv0.zy).r;
					// half mask = tex2D(_NoiseTex, i.uv0.wy).r;
					// half maskFade = tex2D(_NoiseFadeTex, i.uv0.xy).r;
					// main = erode(main,0.5+maskFade*0.5);
					// //main *= mask;
					// main = lerp(main*mask, main, clamp(maskFade-0.2,0,1));


					half3 col = tex2D(_LUT, half2(combined,0)) * i.color.rgb;
					//half4 col = tex2D(_ColorTex, half2(main,0));//i.uv0.xy);
					//col.a =  main;// * maskFade * 2;

					return half4(col, combined * i.color.a);
				}
				ENDCG 
			}
		}	
	}
}
