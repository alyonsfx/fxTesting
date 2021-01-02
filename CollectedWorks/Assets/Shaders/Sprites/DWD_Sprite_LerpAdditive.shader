//© Dicewrench Designs LLC 2020
//All Rights Reserved, used with permission
//Last Owned by: Allen White (allen@dicewrenchdesigns.com)


Shader "Custom/DWD/Sprites/Lerp Color + Additive Channels"
{
   Properties
   {
      [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
      _Color ("Tint", Color) = (1, 1, 1, 1)

      [Header(R Gradient Lerp)]
      _RedColor("R Zero Color", Color) = (1,1,1,1)
      _RedColorTwo("R One Color", Color) = (0,0,0,0)

      [Header(Additive Channels)]
      _GreenColor("Green Glow Color", Color) = (1,1,1,1)

      _BlueColor("Blue Glow Color", Color) = (1,1,1,1)

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
      Blend One OneMinusSrcAlpha

      Pass
      {
         CGPROGRAM
            
         #pragma vertex SpriteVert
         #pragma fragment frag
         #pragma target 2.0
         #pragma multi_compile_instancing
         #pragma multi_compile _ PIXELSNAP_ON
         #pragma multi_compile _ ETC1_EXTERNAL_ALPHA

         #include "UnitySprites.cginc"
         #include "../DWD_ShaderFunctions.cginc"
         #include "../DWD_NoiseFunctions.cginc"

         fixed4 _RedColor, _RedColorTwo, _GreenColor, _BlueColor;

         half4 frag(v2f IN): SV_Target
         {
            half4 c = SampleSpriteTexture(IN.texcoord.xy);
            
            half3 base = lerp(_RedColor.rgb, _RedColorTwo.rgb, c.r);
            base = saturate(base + (_GreenColor.rgb * c.ggg * _GreenColor.aaa));
            base = saturate(base + (_BlueColor.rgb * c.bbb * _BlueColor.aaa));

            return half4(base,c.a) * IN.color;
         }
            
         ENDCG        
      }
   }
}