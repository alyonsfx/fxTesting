Shader "Custom/FX/Fresnel Texture Additive"
{
	Properties 
    {
		_Color("Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_RimWidth("Rim Width", Float) = 1
		_RimPower("Rim Intensity", Float) = 1
    }

    SubShader 
	{
		Tags{"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		LOD 100

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
			sampler2D _MainTex;
			half _RimWidth, _RimPower;
		
			struct appdata
			{
				half4 vertex : POSITION;
				half3 normal : NORMAL;
				half2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				half4 pos : SV_POSITION;
				half color : COLOR;
				half2 uv : TEXCOORD0;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.color = fresnel(v.vertex, v.normal);
				return o;
			}

			half4 frag (v2f i) : SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv) * _Color;
				col *= fresnelFalloff(i.color, _RimWidth, _RimPower);
				return col;
			}
            ENDCG           
        }
    }
}