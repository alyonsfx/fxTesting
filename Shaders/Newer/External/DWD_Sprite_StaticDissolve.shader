//© Dicewrench Designs LLC 2020
//All Rights Reserved, used with permission
//Last Owned by: Allen White (allen@dicewrenchdesigns.com)


Shader "Custom/DWD/Sprites/Static Dissolve"
{
   Properties
   {
      [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
      _Color ("Tint", Color) = (1, 1, 1, 1)

      [Header(Screen FX Settings)]
      [NoScaleOffset] _Screen("Screen Data Tex", 2D) = "black" {}

      [Header(Scanline Settings)]      
      _LineTiling("Scanline Tiling", Float) = 1.0
      _Width ("Scanline Width", Range(-1,1)) = 0.0
            
      [Header(Static Settings)]
      _StaticIntensity("Static Intensity", Range(0,1)) = 0.2
      _StaticScale ("Static Scale", Float) = 0.15
      _Scroll ("Scroll Rate", Float) = 0.0

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
         #pragma multi_compile_instancing
         #pragma multi_compile _ PIXELSNAP_ON
         #pragma multi_compile _ ETC1_EXTERNAL_ALPHA

         #include "UnityCG.cginc"
         #include "../DWD_ShaderFunctions.cginc"
         #include "../DWD_NoiseFunctions.cginc"

         sampler2D _Screen;
         float _LineTiling, _Scroll, _StaticIntensity, _StaticScale;

         #ifndef UNITY_SPRITES_INCLUDED
         #define UNITY_SPRITES_INCLUDED
         #define UNITY_INSTANCING_ENABLED

         #ifdef UNITY_INSTANCING_ENABLED
            UNITY_INSTANCING_BUFFER_START(PerDrawSprite)
               UNITY_DEFINE_INSTANCED_PROP(fixed4, unity_SpriteRendererColorArray)
               UNITY_DEFINE_INSTANCED_PROP(fixed2, unity_SpriteFlipArray)
               UNITY_DEFINE_INSTANCED_PROP(float, _Width)
            UNITY_INSTANCING_BUFFER_END(PerDrawSprite)

            #define _RendererColor  UNITY_ACCESS_INSTANCED_PROP(PerDrawSprite, unity_SpriteRendererColorArray)
            #define _Flip           UNITY_ACCESS_INSTANCED_PROP(PerDrawSprite, unity_SpriteFlipArray)
         #endif

         CBUFFER_START(UnityPerDrawSprite)
         #ifndef UNITY_INSTANCING_ENABLED
            fixed4 _RendererColor;
            fixed2 _Flip;
            float _Width;
         #endif
            float _EnableExternalAlpha;
         CBUFFER_END

         sampler2D _MainTex;
         sampler2D _AlphaTex;
         fixed4 _Color;

         struct appdata_t
         {
            float4 vertex   : POSITION;
            float4 color    : COLOR;
            float2 texcoord : TEXCOORD0;
            UNITY_VERTEX_INPUT_INSTANCE_ID
         };

         struct fragInput
         {
            float4 vertex   : SV_POSITION;
            fixed4 color    : COLOR;
            float3 coords : TEXCOORD0;
            UNITY_VERTEX_OUTPUT_STEREO
         };

         inline float4 UnityFlipSprite(in float3 pos, in fixed2 flip)
         {
            return float4(pos.xy * flip, pos.z, 1.0);
         }

         fragInput vert(appdata_t IN)
         {
            fragInput OUT;

            UNITY_SETUP_INSTANCE_ID (IN);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

            OUT.vertex = UnityFlipSprite(IN.vertex, _Flip);
            OUT.vertex = UnityObjectToClipPos(OUT.vertex);
            OUT.coords.xy = IN.texcoord.xy;
            OUT.coords.z = _Time.x * _Scroll;
            OUT.color = IN.color * _Color * _RendererColor;

            #ifdef PIXELSNAP_ON
               OUT.vertex = UnityPixelSnap (OUT.vertex);
            #endif

            return OUT;
         }

         fixed3 GetScreenColor (fixed4 edge, fixed4 glow, fixed gradient, fixed mask)
         {
            return saturate(lerp(edge.rgb,glow.rgb,gradient) * mask.xxx);
         }

         fixed4 SampleSpriteTexture (float2 uv)
         {
            fixed4 color = tex2D (_MainTex, uv);

            #if ETC1_EXTERNAL_ALPHA
               fixed4 alpha = tex2D (_AlphaTex, uv);
               color.a = lerp (color.a, alpha.r, _EnableExternalAlpha);
            #endif

            return color;
         }

         half4 frag(fragInput IN): SV_Target
         {
            half4 c = SampleSpriteTexture(IN.coords.xy) * IN.color;
            c.rgb *= c.aaa;

            float width = UNITY_ACCESS_INSTANCED_PROP(PerDrawSprite, _Width);

            half scanline = ZeroOneZero(frac(IN.coords.y * _LineTiling)) - width;
            half fx = saturate(tex2D(_Screen,float2(IN.coords.z, IN.coords.y * _StaticScale)).r + (1.0 - _StaticIntensity));

            half dissolve = lerp(1.0, fx, saturate(scanline));
            c.a *= dissolve;
            c.a = saturate(c.a + (min(0.0, width)));

            c.rgb *= saturate(c.a);
            return c;
         }
         #endif
         ENDCG        
      }
   }
}