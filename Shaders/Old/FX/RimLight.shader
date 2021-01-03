// Creates an additive rim light effect using the object's facing angle
Shader "Custom/FX/Rim Light"
{
	Properties 
    {
		_CenterColor("Center Color", Color) = (0,0,0,1)
		_EdgeColor("Edge Color", Color) = (1,1,1,1)
		_RimWidth("Rim Width", Float) = 2.75
		_RimPower("Rim Intensity", Float) = 4.0
		_Angle ("Rim Light World Direction (XYZ)", Vector) = (-0.8,0.2,1.0,0.0)
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
		
			half4 _CenterColor, _EdgeColor, _Angle;
			half _RimWidth, _RimPower;

			v2f_vf vert (appdata_vn v)
			{
				v2f_vf o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = rimLight(v.normal, _Angle.xyz);
				return o;
			}

			half4 frag (v2f_vf i) : SV_Target
			{
				half mask = fresnelFalloff(i.color, _RimWidth, _RimPower);
				half4 col = lerp(_CenterColor, _EdgeColor, 1 - mask);
				UNITY_OPAQUE_ALPHA(col.a);
				return col;
			}
            ENDCG           
        }
    }
}