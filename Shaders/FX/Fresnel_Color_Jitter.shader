Shader "Custom/FX/Fresnel Color Jitter"
{
	Properties 
    {
		_CenterColor("Center Color", Color) = (0.5,0.5,0.5,1)
		_EdgeColor("Edge Color", Color) = (1,1,1,1)
		_RimWidth("Rim Width", Float) = 1
		_RimPower("Rim Intensity", Float) = 1
		_JitterDistance ("Jitter Distance", Float ) = .7
		_JitterSpeed ("Jitter Speed", Float ) = 2.7
		_JitterWidth("Jitter Mask Width", Float) = .31
		_JitterPower("Jitter Mask Intensity", Float) = 2.17
    }

    SubShader 
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry" "DisableBatching" = "True" "IgnoreProjector"="True" }
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
			half _RimWidth, _RimPower, _JitterDistance, _JitterSpeed, _JitterWidth, _JitterPower;

			v2f_vf vert (appdata_vn v)
			{
				v2f_vf o;
				half3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
				half jittermask = fresnel(viewDir, v.normal, _JitterWidth, _JitterPower);
				v.vertex.xyz = jitter(_JitterDistance, _JitterSpeed, clamp(jittermask,0,1), v.normal, v.vertex);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = fresnel(viewDir, v.normal);
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