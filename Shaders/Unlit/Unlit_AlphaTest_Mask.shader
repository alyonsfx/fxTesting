
Shader "Unlit/Transparent Cutout (Mask)"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MaskTex ("Mask Texture (R)", 2D) = "white" {}
		_Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5
	}

	SubShader{
		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 2.0
			
			#include "UnityCG.cginc"

			sampler2D _MainTex, _MaskTex;
			half4 _MainTex_ST, _MaskTex_ST;
			half _Cutoff;

			struct appdata_vu
			{
			    half4 vertex : POSITION;
			    half2 texcoord : TEXCOORD0;
			};

			struct v2f {
				half4 pos : SV_POSITION;
				half2 uv0 : TEXCOORD0;
				half2 uv1 : TEXCOORD1;

			};

			v2f vert (appdata_vu v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv0 = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.uv1 = TRANSFORM_TEX(v.texcoord,_MaskTex);
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv0);
				half4 mask = tex2D(_MaskTex, i.uv1);
				clip(mask.r - _Cutoff);
				return col;
			}
			ENDCG
		}
	}
}
