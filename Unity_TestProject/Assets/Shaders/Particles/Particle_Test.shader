Shader "Custom/Particles/Uber"
{
	Properties
	{
        [Header(Basics)][Space]
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
        [Toggle(ERODE_ON)] _Erode("Alpha Erossion", Int) = 0
        _ErodeAmount("Alpha Offset", Range(0,1)) = 0
        [Space(10)][Header(Tags)][Space]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", Int) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("Source Blend Mode", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Destination Blend Mode", Float) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("ZTest", Float) = 4 //"LessEqual"
        [Enum(Off,0,On,1)] _ZWrite("ZWrite", Float) = 1.0 //"On"
	}

	Category
	{
		SubShader
		{
			Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }

			Pass
			{
				Blend [_SrcBlend] [_DstBlend]
				Cull [_Cull]
				ZWrite [_ZWrite]
                ZTest [_ZTest]

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma target 2.0

				#include "UnityCG.cginc"
                #include "../Family.cginc"
                #pragma shader_feature ERODE_ON

				half4 _TintColor, _MainTex_ST;
				sampler2D _MainTex;
                half _ErodeAmount;
                
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
                    #if ERODE_ON
                    o.uv.z = (1-_ErodeAmount) * (1-v.texcoord0.z);
                    #endif
                    return o;
                }
				
				half4 frag (v2f i) : SV_Target
				{
					half4 col = i.color * tex2D(_MainTex, i.uv);
                    #if ERODE_ON
                    col.a = erode(col.a, i.uv.z);
                    #endif
                    return col;
				}
				ENDCG
			}
		}	
	}
}