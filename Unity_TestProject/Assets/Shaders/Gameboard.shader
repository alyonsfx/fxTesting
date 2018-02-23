Shader "Custom/Gameboard"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "grey" {}
		_DetailTint ("Detail Tint", Color) = (1,1,1,1)
		_Detail ("Additive Worldspace Detail Texture (RGB) Mask (A)", 2D) = "black" {}
		_Color1 ("+Z Color", Color) = (1,1,1,1)
		_Color2 ("-Z Color", Color) = (0,0,0,1)
		_Offset ("Z Scale", Float) = 1
		_VertexTintG ("Green Vertex Tint (RGB) Intensity (A)", Color) = (0,1,0,0)
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry" }
		LOD 100
		
		Pass
		{  
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 2.0

			#include "UnityCG.cginc"

			sampler2D _MainTex, _Detail;
			fixed4 _Color1, _Color2, _DetailTint, _VertexTintG;
			float4 _MainTex_ST, _Detail_ST;
			float _Offset;
			
			struct appdata_t
			{
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed4 color0 : COLOR0;
				fixed4 color1 : COLOR1;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
			};

			v2f vert (appdata_t v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv1 = mul (unity_WorldToObject, v.vertex).xz;
				o.color0 = v.color;
				_Offset *= 0.1 * o.uv1.y;
				_Offset += 0.5;
				saturate(_Offset);
				o.color1 = lerp(_Color2, _Color1, _Offset);// * v.color;
				o.uv0 = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv1 = TRANSFORM_TEX(o.uv1, _Detail);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col =  i.color1 * tex2D(_MainTex, i.uv0);
				fixed4 over = tex2D(_Detail, i.uv1) * _DetailTint;
				col.rgb = lerp (col, col + over, over.a).rgb;
				col.rgb = lerp (col, _VertexTintG, i.color0.g * _VertexTintG.a); 
				return col;
			}
			ENDCG
		}
	}	
}