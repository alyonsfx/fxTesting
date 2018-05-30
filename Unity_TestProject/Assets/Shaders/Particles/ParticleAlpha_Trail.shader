Shader "Custom/Particles/Alpha Blended (Scrolling Trail)"
{
	Properties
	{
		_MainTex ("Particle Texture", 2D) = "white" {}
        _NoiseTex ("Noise", 2D) = "white" {}
		_NoiseFadeTex ("NoiseFade", 2D) = "white" {}
		_ColorTex ("Color", 2D) = "white" {}
		_Scroll ("Scroll Speed - Main (XY) Mask (ZW)", Vector) = (0,0,0,0)
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

				sampler2D _MainTex, _NoiseTex, _NoiseFadeTex, _ColorTex;
				half4 _Color1, _Color2, _Scroll, _NoiseTex_ST;

                struct appdata
                {
                    float4 vertex : POSITION;
                    half4 texcoord0 : TEXCOORD0;
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
					half2 temp = TRANSFORM_TEX(v.texcoord0,_NoiseTex);
					o.uv0.zw = scrollUVs(half2(o.uv0.x,temp.x), _Scroll.xy);
					return o;
				}
				
				half4 frag (v2f i) : SV_Target
				{
					half main = tex2D(_MainTex, i.uv0.zy).r;
					half mask = tex2D(_NoiseTex, i.uv0.wy).r;
					half maskFade = tex2D(_NoiseFadeTex, i.uv0.xy).r;
					main = erode(main,0.5+maskFade*0.5);
					//main *= mask;
					main = lerp(main*mask, main, clamp(maskFade-0.2,0,1));

					half4 col = tex2D(_ColorTex, half2(main,0));//i.uv0.xy);
					col.a =  main;// * maskFade * 2;

					return col * i.color;
				}
				ENDCG 
			}
		}	
	}
}
