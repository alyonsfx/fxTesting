Shader "Custom/FX/Fresnel Color Additive"
{
	Properties 
    {
		_Color("Color", Color) = (1,1,1,1)
		_RimWidth("Rim Width", Float) = 1
		_RimPower("Rim Intensity", Float) = 1
		_AlphaOffset("Alpha Offset", Range (-1, 1)) = 0
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
		
			half4 _Color;
			half _RimPower, _RimWidth, _AlphaOffset;
		
			v2f_vf vert (appdata_vn v)
			{
				v2f_vf o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = fresnel(v.vertex, v.normal);
				return o;
			}

			half4 frag (v2f_vf i) : SV_Target
			{
				return _Color * fresnelFalloff(i.color, _RimWidth, _RimPower, _AlphaOffset);
			}
            ENDCG           
        }
    }
}