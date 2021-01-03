//© Dicewrench Designs LLC 2020
//All Rights Reserved, used with permission
//Last Owned by: Allen White (allen@dicewrenchdesigns.com)


Shader "Custom/DWD/Sprites/Tiled Minos"
{
   Properties
   {
      [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
      //red = lit edges //green = shadow edges //blue = base value //alpha = phase offset

      [Header(Color Settings)]
      _Color ("Main Color", Color) = (0.5, 0.5, 0.5, 1)
      _BevelHighlight ("Bevel Highlight", Color) = (1,1,1,1)
      _BevelShadow ("Bevel Shadow", Color) = (0,0,0,0)

      [Header(World UVs)]
      _Top("Top", Float) = 50.0
      _Bottom("Bottom", Float) = -50.0

      [Header(Lit Edge Glow)]
      _LitColorOne("Lit Color One", Color) = (0,0,0,0)
      _LitColorTwo("Lit Color Two", Color) = (1,0,0,0)
      [Space]
      _LitWipeProgress("Lit Wipe", Range(-0.25,1.25)) = 0.0
      _LitWipeContrast("Lit Wipe Contrast", Float) = 10.0
      [Space]
      _LitWipeColor("Wipe Color", Color) = (1,1,1,1)
      _LitWipeThickness("Wipe Thickness", Float) = 2.0
      _LitWipeTrailContrast("Wipe Contrast", Float) = 10.0
      [Space]
      _HotThickness("Edge Thickness", Float) = 0.2
      _HotContrast("Edge Contrast", Float) = 10.0

      [Header(Mino Shine)]
      _MinoShineColor("Shine Color", Color) = (1,1,1,1)
      _MinoShineProgress("Shine Progress", Range(-0.25,1.25)) = 0.0
      _MinoShineThickness("Shine Thickness", Float) = 2.0
      _MinoShineContrast("Shine Contrast", Float) = 10.0

      [Header(Height Modifier)]
      _NoiseColor("Depth/Shadow Color", Color) = (0.5,0.5,0.5,0.5)
      [Space]
      _ShadowProgress("Shadow Progress Offset", Range(-1.25,1.25)) = 0.0
      _ShadowThickness("Shadow Thickness", Float) = 2.0
      _ShadowContrast("Shadow Contrast", Float) = 10.0
      _NoisePow("Shadow Power", Float) = 3.0

      [Header(Height Noise)]
      _NoiseSteps("Noise Step Count", Float) = 45.0
      _NoiseRate("Noise Rate", Float) = 0.3
      _NoiseIntensity("Noise Intensity", Range(0,1)) = 0.0      
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

         #include "UnitySprites.cginc"
         #include "../DWD_ShaderFunctions.cginc"

         float _Top, _Bottom;
         fixed4 _BevelHighlight, _BevelShadow;
         float _LitWipeContrast, _LitWipeProgress, _LitWipeThickness, _LitWipeTrailContrast;
         float _MinoShineContrast, _MinoShineProgress, _MinoShineThickness;
         float _HotThickness, _HotContrast;
         float _NoiseIntensity, _NoiseRate, _NoiseSteps, _ShadowContrast, _ShadowProgress, _ShadowThickness, _NoisePow;
         fixed4 _NoiseColor;
         fixed4 _LitColorOne, _LitColorTwo, _LitWipeColor, _MinoShineColor;

         struct vert2frag
         {
            float4 vertex : SV_POSITION;
            fixed4 color : COLOR;
            float4 coords : TEXCOORD0;
            float time : TEXCOORD1;
            UNITY_VERTEX_OUTPUT_STEREO
         };

         vert2frag vert(appdata_t IN)
         {
            vert2frag OUT;

            UNITY_SETUP_INSTANCE_ID (IN);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

            OUT.vertex = UnityFlipSprite(IN.vertex, _Flip);
            OUT.vertex = UnityObjectToClipPos(OUT.vertex);

            OUT.coords.xy = IN.texcoord;
            
            float scale = _Top - _Bottom;
            float3 worldPos = mul(unity_ObjectToWorld, IN.vertex).xyz;
            OUT.coords.zw = saturate((worldPos.xy - float2(0,_Bottom))/scale);

            OUT.color = IN.color * _Color;

            float t = _Time.x;
            OUT.time = t * _NoiseRate;

            #ifdef PIXELSNAP_ON
               OUT.vertex = UnityPixelSnap(OUT.vertex);
            #endif

            return OUT;
         }


         half4 frag(vert2frag IN): SV_Target
         {
            half4 c = SampleSpriteTexture(IN.coords.xy);
            half4 color = IN.color;

            half alpha = c.b * 0.5;
            half shadowProg = IN.coords.w - _ShadowProgress - _LitWipeProgress;
            half shadowThickness = _ShadowThickness * 0.05;
            half shadowMask = saturate(saturate( shadowProg + shadowThickness) * _ShadowContrast);
            half invShadow = 1.0 - saturate(saturate( shadowProg - shadowThickness) * _ShadowContrast); 
            shadowMask = saturate((shadowMask * invShadow - alpha) * 100.0);

            float n = frac(IN.time);
            n = ZeroOneZero(n);
            half noise = (1.0 - distance(c.b, n)) * _NoiseIntensity;
            noise = saturate(pow(noise + shadowMask, _NoisePow));

            half bevelEdge = saturate(c.r - noise);
            half shadowEdge = saturate(c.g - noise);

            float prog = saturate(IN.coords.w - _LitWipeProgress);
            half wipeMask = 1.0 - saturate(prog * _LitWipeContrast);
            half wipeThickness = _LitWipeThickness * 0.05;
            half trailMask = saturate(saturate(IN.coords.w - _LitWipeProgress + wipeThickness) * _LitWipeTrailContrast) * wipeMask;
            half hotMask = saturate(saturate(IN.coords.w - _LitWipeProgress + _HotThickness * 0.05) * _HotContrast) * wipeMask;
            half shineMask = saturate(saturate(IN.coords.w - _MinoShineProgress + _MinoShineThickness * 0.05) * _MinoShineContrast);
            half invShine = 1.0 - saturate(saturate(IN.coords.w - _MinoShineProgress - _MinoShineThickness * 0.05) * _MinoShineContrast);
            shineMask = shineMask * invShine * (1.0 - c.r);

            color = lerp(color, _BevelHighlight, bevelEdge);
            color = lerp(color, _BevelShadow, shadowEdge);
            color = lerp(color, _NoiseColor, (noise) * _NoiseColor.a);

            half4 lit = saturate(lerp(_LitColorOne, _LitColorTwo, wipeMask) * bevelEdge.xxxx);
            half litKnockout = (lit.r + lit.g + lit.b) * 0.333;
            color.rgb -= litKnockout.xxx;

            color.rgb += lit.rgb;
            color.rgb += _LitWipeColor.rgb * trailMask.xxx;
            color.rgb += _MinoShineColor.rgb * (shineMask * (1.0 - noise)).xxx;
            color.rgb += hotMask.xxx;

            color.rgb = saturate(color.rgb);
            color.a = 1.0;
            return color;
         }
         ENDCG        
      }
   }
}