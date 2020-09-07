// Uses a reflection cube to add highlights based on 2 intances of the same normal map
// An additive detail map is also applied
// Vertex color is used to vertically animate the mesh's verts
Shader "Rocket Boy/Environment/Water (Vertex Colored Alpha)"
{
 Properties
 {
     _JitterDistance ("Jitter Distance (Vert Color R)", Float ) = .01
     _JitterSpeed ("Jitter Speed", Float ) = .01
     _Color ("Reflection Tint (RGB) Transparency (A)", Color) = (0,0,0,1)
     _Cube ("Reflection Cubemap", Cube) = "" {}
     _DetailPower ("Foam Intensity", Range (0.0, 1)) = 0.75
     _DetailMap ("Additive Foam Map", 2D) = "black" {}
     _Normal1Power ("Normal 1 Intensity", Range (0.0, 1)) = 1
     _Normal2Power ("Normal 2 Intensity", Range (0.0, 1)) = 1
     _NormalMap ("Normal Map", 2D) = "bump" {}
     _NormalMapOffset ("Normal Map Offset (Set 1 XY) (Set 2 ZW)", Vector) = (0, 0, 0, 0)
 }

 SubShader
 {       
     Lighting Off
     Blend One One
     ColorMask RGBA
     ZWrite Off
     Alphatest Greater 0
     Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "ForceNoShadowCasting"="True" }
     LOD 400
     
     CGPROGRAM
     #pragma surface surf Lambert vertex:vert alpha nolightmap nodirlightmap 
     #pragma multi_compile JITTER_ON JITTER_OFF
     #pragma target 3.0
     
     #include "UnityCG.cginc"
     #include "RocketBoy.cginc"

     sampler2D _NormalMap, _DetailMap;
     samplerCUBE _Cube;
     fixed4 _SpecularColor, _Color, _NormalMapOffset;
     fixed _JitterDistance, _JitterSpeed, _Shininess, _DetailPower, _Normal1Power, _Normal2Power;
     
     struct Input {
         float2 uv_NormalMap;
         float2 uv_DetailMap;
         float3 worldRefl;
         fixed3 transMask;
         INTERNAL_DATA
     };              
     
     void vert (inout appdata_full v, out Input o)
     {
         UNITY_INITIALIZE_OUTPUT(Input, o);
#if defined (JITTER_ON)
         v.vertex.xyz = jitter(_JitterDistance, _JitterSpeed, _Time, v.color, v.normal, v.vertex.xyz);
#endif
         o.transMask = v.color.a;
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
         foam *= _DetailPower;
         
         //Reflections
         float3 worldRefl = WorldReflectionVector (IN, o.Normal);
         fixed4 reflcol = texCUBE (_Cube, worldRefl);
         reflcol *= _Color;
         
         o.Albedo = reflcol + foam;
         o.Alpha =_Color.a * IN.transMask;
         }
     ENDCG
 }
}