//© Dicewrench Designs LLC 2020
//All Rights Reserved, used with permission
//Last Owned by: Allen White (allen@dicewrenchdesigns.com)


Shader "Custom/DWD/Sprites/Noise Flicker"
{
   Properties
   {
      [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
      _Color ("Tint", Color) = (1, 1, 1, 1)

      [Header(Mask Settings)]
      _Red("Red Channel", Range(0,1)) = 1.0
      _Green("Green Channel", Range(0,1)) = 0.0
      _Blue("Blue Channel", Range(0,1)) = 0.0

      [Header(Noise Color Mul)]
      _Rate("Rate", Float) = 1.0
      [Space]
      _Pow("Pow", Float) = 0.5
      _Boost("Boost", Float) = 1.0
      [Space]
      _Min("Min", Float) = 0.25
      _Max("Max", Float) = 1.5
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
      Blend One One

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
         #include "../DWD_NoiseFunctions.cginc"

         float _Rate, _Pow, _Boost, _Min, _Max;
         half _Red, _Green, _Blue;

         struct fragInput
         {
            float4 vertex   : SV_POSITION;
            fixed4 color    : COLOR;
            float3 coords : TEXCOORD0; //xy = uv //z = flicker
            UNITY_VERTEX_OUTPUT_STEREO
         };


         fragInput vert(appdata_t IN)
         {
            fragInput OUT;

            UNITY_SETUP_INSTANCE_ID (IN);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

            OUT.vertex = UnityFlipSprite(IN.vertex, _Flip);
            OUT.vertex = UnityObjectToClipPos(OUT.vertex);
            OUT.color = IN.color * _Color * _RendererColor;

            float t = _Time.x * _Rate;
            OUT.coords.xy = IN.texcoord.xy;
            OUT.coords.z = clamp(pow(Noise(t.xx), _Pow) * _Boost, _Min, _Max);

            #ifdef PIXELSNAP_ON
               OUT.vertex = UnityPixelSnap (OUT.vertex);
            #endif

            return OUT;
         }

         half4 frag(fragInput IN): SV_Target
         {
            half4 c = SampleSpriteTexture(IN.coords.xy);
            half mask = saturate( (c.r * _Red) + (c.g * _Green) + (c.b * _Blue) );

            half4 col = IN.color * IN.coords.zzzz;
            return mask.xxxx * col;
         }
            
         ENDCG        
      }
   }
}