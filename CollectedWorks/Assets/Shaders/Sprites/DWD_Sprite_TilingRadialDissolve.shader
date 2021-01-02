//© Dicewrench Designs LLC 2020
//All Rights Reserved, used with permission
//Last Owned by: Allen White (allen@dicewrenchdesigns.com)


Shader "Custom/DWD/Sprites/Tiling Radial Dissolve"
{
   Properties
   {
      [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
      _Color ("Tint", Color) = (1, 1, 1, 1)
      _ScaleOffset("Scale Offset", Vector) = (1,1,0,0)
      _Boost("Boost", Float) = 2.0

      [Header(Gradient)]
      _GradColor("Gradient Color", Color) = (1,1,1,0)
      [Space]
      _Offset("Offset", Float) = 0.0
      _Contrast("Contrast", Float) = 1.0
      [Space]
      _Height("Sprite Height Blend", Range(0,1)) = 1.0


      [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
      [HideInInspector] _RendererColor ("RendererColor", Color) = (1, 1, 1, 1)
      [HideInInspector] _Flip ("Flip", Vector) = (1, 1, 1, 1)
      [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" { }
      [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
   }

   SubShader
   {
      Tags 
      { 
         "Queue" = "Transparent" 
         "IgnoreProjector" = "True" 
         "RenderType" = "Transparent" 
         "PreviewType" = "Plane" 
         "CanUseSpriteAtlas" = "True" 
      }

      Cull Off
      Lighting Off
      ZWrite Off
      Blend SrcAlpha OneMinusSrcAlpha

      Pass
      {
         CGPROGRAM
            
         #pragma vertex vert
         #pragma fragment frag
         #pragma target 2.0
         #pragma multi_compile_instancing
         #pragma multi_compile _ PIXELSNAP_ON
         #pragma multi_compile _ ETC1_EXTERNAL_ALPHA

         #include "UnitySprites.cginc"
         #include "../DWD_ShaderFunctions.cginc"

         float4 _ScaleOffset;
         fixed4 _GradColor;
         float _Offset, _Contrast, _Height, _Boost;

         struct fragInput
         {
            float4 vertex   : SV_POSITION;
            fixed4 color    : COLOR;
            float4 coords : TEXCOORD0;
            UNITY_VERTEX_OUTPUT_STEREO
         };


         fragInput vert (appdata_t IN)
         {
            fragInput OUT;

            UNITY_SETUP_INSTANCE_ID (IN);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

            OUT.vertex = UnityFlipSprite(IN.vertex, _Flip);
            OUT.vertex = UnityObjectToClipPos(OUT.vertex);
            OUT.coords.xy = IN.texcoord;
            OUT.coords.zw = IN.texcoord * _ScaleOffset.xy + _ScaleOffset.zw;
            OUT.color = IN.color * _Color * _RendererColor;

            #ifdef PIXELSNAP_ON
               OUT.vertex = UnityPixelSnap (OUT.vertex);
            #endif
            return OUT;
         }

         float RadialGradient(float2 uv, float angle, float offset, float contrast)
         {
            float2 gradUV = ComputeRotatedUV(uv, angle);
            float grad = saturate(distance(gradUV.xy, float2(0.5,0.5)));
            float final = saturate((grad + offset - angle) * contrast);
            return final;
         }

         half4 frag(fragInput IN): SV_Target
         {
            half4 c = saturate(SampleSpriteTexture(IN.coords.zw) * IN.color + _Boost);
            half cAvg = (c.r + c.g + c.b) * 0.333;
            half grad = 1.0 - RadialGradient(IN.coords.xy, 0.0, _Offset, _Contrast);
            
            grad = lerp(grad, grad * cAvg, _Height);

            c = lerp(c, c * _GradColor, grad);
            ///c.rgb  *= c.aaa;

            return c;
         }
            
         ENDCG        
      }
   }
}