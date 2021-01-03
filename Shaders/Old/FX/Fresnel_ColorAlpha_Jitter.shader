Shader "Custom/FX/Fresnel Color Alpha Jitter"
{
	Properties 
    {
		_Color("Color", Color) = (1,1,1,1)
		_RimWidth("Rim Width", Float) = 1
		_RimPower("Rim Intensity", Float) = 1
		_AlphaOffset("Alpha Offset", Range (-1, 1)) = 0
		_JitterDistance ("Jitter Distance", Float ) = .7
		_JitterSpeed ("Jitter Speed", Float ) = 2.7
    }

    SubShader 
	{
		Tags{ "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching" = "True" }
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off

            CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "../Family.cginc"
		
			half4 _Color;
			half _RimWidth, _RimPower, _AlphaOffset, _JitterDistance, _JitterSpeed;
		
			v2f_vf vert (appdata_vn v)
			{
				v2f_vf o;
				v.vertex.xyz = jitter(_JitterDistance, _JitterSpeed, 1, v.normal, v.vertex);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = fresnel(v.vertex, v.normal);
				return o;
			}

			half4 frag (v2f_vf i) : SV_Target
			{
				half4 col = _Color;
				col.a *= fresnelFalloff(i.color, _RimWidth, _RimPower, _AlphaOffset);
				return col;
			}
            ENDCG           
        }
    }
}