//© Dicewrench Designs LLC 2020
//All Rights Reserved, used with permission
//Last Owned by: Allen White (allen@dicewrenchdesigns.com)


Shader "Custom/DWD/Sprites/Scrolling Wave"
{
   //R channel = mask
   //G channel = scroll
   Properties
   {
      [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
      _Color ("Tint", Color) = (1, 1, 1, 1)
      _ColorBoost("Color Boost", Float) = 1.0

      [Header(Green Channel Scrolling)]
      _XScroll("X Scroll", Float) = 0.0
      _YScroll("Y Scroll", Float) = 1.0

      [Header(Wave Settings)]
      [KeywordEnum(UV, Screen, World)] _UVMode("UV Mode", Float) = 0.0
       [Space]
      _WaveRate ("Wave Rate", Float) = 0.0
      _WaveScale ("Wave Scale", Float) = 2.0
      _WaveIntensity("Wave Intensity", Float) = 1.0
      [Space]
      _XIntensity("X Intensity", Range(0,1)) = 1.0
      _YIntensity("Y Intensity", Range(0,1)) = 0.5

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
            
         #pragma vertex vert
         #pragma fragment frag
         #pragma target 2.0
         #pragma multi_compile _SPRITEMODE_DEFAULT _SPRITEMODE_MASK
         #pragma multi_compile _UVMODE_UV _UVMODE_SCREEN _UVMODE_WORLD
         #pragma multi_compile_instancing
         #pragma multi_compile _ PIXELSNAP_ON
         #pragma multi_compile _ ETC1_EXTERNAL_ALPHA

         #include "UnitySprites.cginc"
         #include "/../DWD_NoiseFunctions.cginc"

         half _ColorBoost;
         float _WaveIntensity, _WaveScale, _WaveRate;
         float _XIntensity, _YIntensity;
         float _XScroll, _YScroll;

         v2f vert(appdata_t IN)
         {
            v2f OUT;

            OUT.vertex = UnityFlipSprite(IN.vertex, _Flip);

            float2 uv = IN.texcoord.xy;

            float waveMask = saturate(IN.texcoord.y);

            #if _UVMODE_UV
               //already set
            #elif _UVMODE_SCREEN
               float4 clip = UnityObjectToClipPos(OUT.vertex);
               uv = clip.xy * float2(1.0,-1.0);
            #elif _UVMODE_WORLD
               float3 worldPos = mul(unity_ObjectToWorld, IN.vertex).xyz;
               uv = worldPos.xy;
            #endif

            uv *= _WaveScale;
            float rate = Noise(uv + (_Time.y * _WaveRate).xx) * 2.0 - 1.0;
            uv = ((float2(_XIntensity, _YIntensity) * rate.xx) * _WaveIntensity.xx);
            OUT.vertex.xy = lerp(OUT.vertex.xy, OUT.vertex.xy + uv, waveMask);
            OUT.vertex = UnityObjectToClipPos(OUT.vertex);

            OUT.texcoord = IN.texcoord;
            OUT.color = IN.color * _Color * _RendererColor;
            OUT.color.rgb *= _ColorBoost;
             
            #ifdef PIXELSNAP_ON
               OUT.vertex = UnityPixelSnap(OUT.vertex);
            #endif

            return OUT;
         }

         half4 frag(v2f IN): SV_Target
         {
            half mask = SampleSpriteTexture(IN.texcoord.xy).r;
            float t = _Time.x;
            half scroll = SampleSpriteTexture(IN.texcoord.xy + (t * float2(_XScroll, _YScroll))).g;

            half4 col = saturate(IN.color * scroll * mask * _ColorBoost);

            return col;
         }

         ENDCG        
      }
   }
}