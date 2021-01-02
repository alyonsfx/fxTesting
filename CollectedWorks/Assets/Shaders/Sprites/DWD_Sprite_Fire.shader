//© Dicewrench Designs LLC 2020
//All Rights Reserved, used with permission
//Last Owned by: Allen White (allen@dicewrenchdesigns.com)


Shader "Custom/DWD/Sprites/Fire"
{
   Properties
   {
      [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
      _Color ("Tint", Color) = (1, 1, 1, 1)

      [Header(Red Sample)]
      _RedX("Red X Scroll", Float) = 0.0
      _RedY("Red Y Scroll", Float) = 0.0
      [Space]
      _RedScale("Red Scale", Float) = 1.0

      [Header(Green Sample)]
      _GreenX("Green X Scroll", Float) = 0.0
      _GreenY("Green Y Scroll", Float) = 0.0
      [Space]
      _GreenScale("Green Scale", Float) = 1.0

      [Header(Blend Settings)]
      _Pow("Pow", Float) = 0.5
      _Boost("Boost", Float) = 1.0

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

         float _RedX, _RedY, _GreenX, _GreenY, _Pow, _Boost;
         float _RedScale, _GreenScale;

         struct fragInput
         {
            float4 vertex   : SV_POSITION;
            fixed4 color    : COLOR;
            float2 base : TEXCOORD0;
            float4 coords : TEXCOORD1;
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

            float t = _Time.x;
            OUT.base = IN.texcoord.xy;
            OUT.coords.xy = IN.texcoord.xy * _RedScale.xx + float2(_RedX * t, _RedY * t);
            OUT.coords.zw = IN.texcoord.xy * _GreenScale.xx + float2(_GreenX * t, _GreenY * t);

            #ifdef PIXELSNAP_ON
               OUT.vertex = UnityPixelSnap (OUT.vertex);
            #endif

            return OUT;
         }

         half4 frag(fragInput IN): SV_Target
         {
            half r = SampleSpriteTexture(IN.coords.xy).r;
            half g = SampleSpriteTexture(IN.coords.zw).g;
            half b = SampleSpriteTexture(IN.base.xy).b;
            
            half blend = r * g * 2.0;
            blend *= b;

            blend = saturate(pow(blend, _Pow) * _Boost);
            half edge = saturate(b * b * 2.0);

            return IN.color * blend.xxxx * edge.xxxx;
         }
            
         ENDCG        
      }
   }
}