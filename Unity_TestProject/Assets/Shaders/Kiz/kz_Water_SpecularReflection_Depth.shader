// Uses a reflection cube to add highlights based on 2 intances of the same normal map
// An additive detail map is applied based on a depth texture
// Vertex color is used to vertically animate the mesh's verts
Shader "Rocket Boy/Environment/Water (Depth Alpha)"
{
	Properties
	{
		_JitterDistance ("Jitter Distance (Vert Color R)", Float ) = .01
		_JitterSpeed ("Jitter Speed", Float ) = .01		
		_Color ("Reflection Tint (RGB) Transparency (A)", Color) = (0,0,0,1)
		_EdgeThreshold("Fade Edge", Float) = 1
		_Cube ("Reflection Cubemap", Cube) = "" {}
		_DetailPower ("Foam Intensity", Range (0.0, 1)) = 0.75
		_FoamThreshold("Foam Edge", Float) = 1
		_DetailMap ("Additive Foam Map", 2D) = "black" {}
		_Normal1Power ("Normal 1 Intensity", Range (0.0, 1)) = 1
		_Normal2Power ("Normal 2 Intensity", Range (0.0, 1)) = 1
		_NormalMap ("Normal Map", 2D) = "bump" {}
		_NormalMapOffset ("Normal Map Offset (Set 1 XY) (Set 2 ZW)", Vector) = (0, 0, 0, 0)
	}

	SubShader
	{		
		Lighting Off
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask RGBA
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "ForceNoShadowCasting"="True" }
		LOD 400
		
		CGPROGRAM
		#pragma surface surf Lambert vertex:vert alpha nolightmap nodirlightmap
		#pragma target 3.0
		
		#include "UnityCG.cginc"
		#include "RocketBoy/RocketBoy.cginc"

		uniform sampler2D _NormalMap, _DetailMap, _CameraDepthTexture;
		samplerCUBE _Cube;
		fixed4 _Color, _NormalMapOffset;
		fixed _JitterDistance, _JitterSpeed, _Shininess, _DetailPower, _Normal1Power, _Normal2Power, _EdgeThreshold, _FoamThreshold;
		
		struct Input {
			float2 uv_NormalMap;
			float2 uv_DetailMap;
			float3 worldRefl;
			half4 projPos;
			INTERNAL_DATA
		};
		
		void vert (inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			v.vertex.xyz = jitter(_JitterDistance, _JitterSpeed, _Time, v.color, v.normal, v.vertex.xyz);
		}

		void surf (Input IN, inout SurfaceOutput o)
		{
			//Bump
			fixed3 Normal1 = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap + _NormalMapOffset.xy));
			fixed3 temp1 = lerp(fixed3(0.5,0.5,1),Normal1,_Normal1Power);
			fixed3 Normal2 = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap + _NormalMapOffset.zw));
			fixed3 temp2 = lerp(fixed3(0.5,0.5,1),Normal2,_Normal2Power);
			fixed3 finalBump = combineNormalMaps(temp1, temp2);
			o.Normal = finalBump;
			
			//Foam
			fixed4 foam = tex2D(_DetailMap, IN.uv_DetailMap + (finalBump.xy * 0.05).r);

			//Depth Texture
			//fixed sceneZ = LinearEyeDepth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos)).r);
			//fixed foamMask = (abs(sceneZ - IN.screenPos.z)) / _FoamThreshold;
			fixed sceneZ = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.projPos)).r);
			float partZ = IN.projPos.z;
			float diff = (abs(sceneZ - partZ)) / _FoamThreshold;
			foam = saturate(foam * (1.0 - diff));
			foam *= _DetailPower;
			
			//Reflections
			float3 worldRefl = WorldReflectionVector (IN, o.Normal);
			fixed4 reflcol = texCUBE (_Cube, worldRefl);
			reflcol *= _Color;
			
			//Final Color
			o.Albedo = reflcol + foam;
			
			//Transparency
			o.Alpha = _Color.a;		
			fixed borderMask = (abs(sceneZ - IN.projPos));
			o.Alpha *= saturate(pow(borderMask,_EdgeThreshold));
		}
		ENDCG
	}
	Fallback "Rocket Boy/Environment/Water (Vertex Colored Alpha)"
}