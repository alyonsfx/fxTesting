Shader "Custom/Particles/Alpha Blended WIP"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
        _Erode ("Alpha Erossion", Range(-1.00,1.00)) = 0
        _ErodeEdge ("Erossion Offset", Range(0.00,1.00)) = 0
        _ErodeFeather ("Erossion Fade", Range(0.00,1.00)) = 0
        _EdgeColor ("Edge Color", Color) = (1,0.2,0,1)
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

				half4 _TintColor, _MainTex_ST, _EdgeColor;
				sampler2D _MainTex;
                half _Erode,_ErodeEdge,_ErodeFeather;
                
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
                    o.color = v.color * _TintColor * 2;
                    o.uv.xy = TRANSFORM_TEX(v.texcoord0.xy,_MainTex);
                    o.uv.z = _Erode;// + v.texcoord0.z;
                    return o;
                }
				
				half4 frag (v2f i) : SV_Target
				{
					half4 col = tex2D(_MainTex, i.uv);
                    //col.a = erode(col.a, i.uv.z);
                    half mask = saturate(i.uv.z + col.a);
                    half colorMask = step(_ErodeEdge,mask);
                    half edge = smoothstep(_ErodeEdge, saturate(_ErodeEdge + (_ErodeEdge * _ErodeFeather)),mask);
                    col.rgb = lerp(_EdgeColor,col*i.color.rgb,edge);
                    col.a = mask*i.color.a;
                    return col;
				}
				ENDCG 
			}
		}	
	}
}