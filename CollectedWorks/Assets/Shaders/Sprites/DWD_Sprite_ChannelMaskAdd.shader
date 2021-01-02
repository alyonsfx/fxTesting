//© Dicewrench Designs LLC 2020
//All Rights Reserved, used with permission
//Last Owned by: Allen White (allen@dicewrenchdesigns.com)


Shader "Custom/DWD/Sprites/Channel Mask Add"
{
   Properties
   {
      [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
      _Color ("Tint", Color) = (1, 1, 1, 1)

      [Header(Channel Mask Colors)]
      _BGColor ("Background Color", Color) = (0,0,0,1)
      [Space]
      _RedColor ("Red Channel Color", Color) = (1,0,0,1)
      _GreenColor ("Green Channel Color", Color) = (0,1,0,1)
      _BlueColor("Blue Channel Color", Color) = (0,0,1,1)

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

         fixed4 _BGColor, _RedColor, _GreenColor, _BlueColor;

         half4 frag(v2f IN): SV_Target
         {
            half4 c = SampleSpriteTexture(IN.texcoord.xy);
            
            half4 base = _BGColor * c.aaaa;

            half3 red = _RedColor.rgb * _RedColor.aaa * c.rrr;
            half3 green = _GreenColor.rgb * _GreenColor.aaa * c.ggg;
            half3 blue = _BlueColor.rgb * _BlueColor.aaa * c.bbb;

            base.rgb += red + green + blue;

            base *= IN.color;

            return base;
         }
            
         ENDCG        
      }
   }
}