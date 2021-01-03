Shader "Custom/Stepped Overlay"
{
	Properties 
    {
		_Color("Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Step("Value Offset", Float) = 0.0
    }

    SubShader 
	{
        Tags{"Queue"="Transparent+1" "IgnoreProjector"="True" "RenderType"="Transparent"}

        Pass
		{
            ZWrite Off
			Blend SrcAlpha One
			Lighting Off

            CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				
				#include "UnityCG.cginc"
			
				fixed4 _Color, _MainTex_ST;
				uniform sampler2D _MainTex;
				fixed _Step;
			
				struct appdata
				{
					fixed4 vertex : POSITION;
					fixed2 texcoord : TEXCOORD0;
				};

				struct v2f
				{
					fixed4 pos : POSITION;
					fixed2 uv : TEXCOORD0;
				};

				v2f vert (appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
					return o;
				}

				fixed4 frag (v2f i) : SV_Target
				{
					fixed4 main = tex2D(_MainTex, i.uv);
					main.xyz += 0.2 * _Step;
					main.xyz = frac(main.xyz);
					fixed4 col = main * _Color;
					return col;
				}
            ENDCG           
        }
    } 
    FallBack "Mobile/Particles/Additive"
}
