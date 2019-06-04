Shader "Custom/FX/Fresnel Color"
{
	Properties 
    {
		_CenterColor("Center Color", Color) = (0,0,0,1)
		_EdgeColor("Edge Color", Color) = (1,1,1,1)
		_RimWidth("Rim Width", Float) = 1
		_RimPower("Rim Intensity", Float) = 1
    }

    SubShader 
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry" "IgnoreProjector"="True" }
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
		
			half4 _CenterColor, _EdgeColor;
			half _RimWidth, _RimPower;

			v2f_vf vert (appdata_vn v)
			{
				v2f_vf o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = fresnel(v.vertex, v.normal);
				return o;
			}

			half4 frag (v2f_vf i) : SV_Target
			{
				half mask = fresnelFalloff(i.color, _RimWidth, _RimPower);
				half4 col = lerp(_CenterColor, _EdgeColor, mask);
				UNITY_OPAQUE_ALPHA(col.a);
				return col;
			}
            ENDCG           
        }
    }
}