// Additive shader using vertex world position to generate UVs
Shader "Custom/FX/Highlight"
{
	Properties 
    {
		_Color("Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_ScrollX("Scroll Speed - Worldspace X", Float) = 0
		_ScrollY("Scroll Speed - Worldspace Y", Float) = 0
    }

    SubShader 
	{
		Tags{"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}

        Pass
		{
			Blend SrcAlpha One
			ZWrite Off

            CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest 
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "../Family.cginc"
		
			half4 _Color, _MainTex_ST;
			uniform sampler2D _MainTex;
			half _ScrollX, _ScrollY;
		
			struct appdata
			{
				half4 vertex : POSITION;
			};

			v2f_vu vert (appdata v)
			{
				v2f_vu o;
				o.pos = UnityObjectToClipPos(v.vertex);
				half3 worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(fixed2(worldPos.z, worldPos.y), _MainTex);
				o.uv = scrollUVs(half2(_ScrollX, _ScrollY), o.uv);
				return o;
			}

			half4 frag (v2f_vu i) : SV_Target
			{
				return tex2D(_MainTex, i.uv) * _Color;
			}
            ENDCG           
        }
    }
}