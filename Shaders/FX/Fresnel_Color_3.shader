Shader "Custom/FX/Fresnel Color+"
{
	Properties 
    {
		_CenterColor("Center Color", Color) = (0.5,0.5,0.5,1)
		_Color2("Step Color", Color) = (0,0,0,1)
		_EdgeColor("Edge Color", Color) = (1,1,1,1)
		_OuterEdge("Outer Edge", Float) = 2
		_InnerEdge("Inner Edge", Float) = 1
    }

    SubShader 
	{
		Tags { "RenderType"="Opaque" "IgnoreProjector"="True" "Queue"="Geometry" }
		LOD 100

		Pass
		{
            CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "../Family.cginc"
		
			half4 _CenterColor, _Color2, _EdgeColor;
			half _OuterEdge, _InnerEdge;

			v2f_vf vert (appdata_vn v)
			{
				v2f_vf o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = fresnel(v.vertex, v.normal);
				return o;
			}

			half4 frag (v2f_vf i) : SV_Target
			{
				half4 mask = i.color;
				half4 col = mask;
				col = lerp(_CenterColor, _Color2, clamp(mask * _OuterEdge,0,1));
				col = lerp(col, _EdgeColor, clamp(mask * _OuterEdge-_InnerEdge,0,1));
				UNITY_OPAQUE_ALPHA(col.a);
				return col;
			}
            ENDCG           
        }
    }
}