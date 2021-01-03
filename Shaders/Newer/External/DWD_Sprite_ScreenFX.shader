//© Dicewrench Designs LLC 2020
//All Rights Reserved, used with permission
//Last Owned by: Allen White (allen@dicewrenchdesigns.com)


Shader "Custom/DWD/Sprites/Screen FX"
{
   Properties
   {
      [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
      _Color ("Tint", Color) = (1, 1, 1, 1)

      [Header(Mask Settings)]
      _RedColor("Red Glow Color", Color) = (1,1,1,1)
      _RedEdgeColor("Red Edge Color", Color) = (0,0,0,0)
      _RedStatic("Red Static", Range(0,1)) = 0.0
      _RedScanlines("Red Scanlines", Range(0,1)) = 0.0
      _RedCorruption("Red Corruption", Range(0,1)) = 0.0
      [Space]
      _GreenColor("Green Glow Color", Color) = (1,1,1,1)
      _GreenEdgeColor("Green Edge Color", Color) = (0,0,0,0)
      _GreenStatic("Green Static", Range(0,1)) = 0.0
      _GreenScanlines("Green Scanlines", Range(0,1)) = 0.0
      _GreenCorruption("Green Corruption", Range(0,1)) = 0.0
      [Space]
      _BlueColor("Blue Glow Color", Color) = (1,1,1,1)
      _BlueEdgeColor("Blue Edge Color", Color) = (0,0,0,0)
      _BlueStatic("Blue Static", Range(0,1)) = 0.0
      _BlueScanlines("Blue Scanlines", Range(0,1)) = 0.0
      _BlueCorruption("Blue Corruption", Range(0,1)) = 0.0

      [Header(Screen FX Settings)]
      [NoScaleOffset] _Screen("Screen Data Tex", 2D) = "black" {}

      [Header(Scanline Settings)]      
      _ScanColorOne("Scan Color One", Color) = (1,1,1,1)
      _ScanColorTwo("Scan Color Two", Color) = (0,0,0,0)
      [Space]
      _LineTiling("Scanline Tiling", Float) = 1.0
      _Width ("Scanline Width", Range(0,1)) = 0.0
      _Contrast("Scanline Contrast", Float) = 2.0
      _Scroll ("Scroll Rate", Float) = 0.0
      
      [Header(Static Settings)]
      _StaticColor("Static Color", Color) = (1,1,1,1)
      _StaticIntensity("Static Intensity", Range(0,1)) = 0.2

      [Header(Corruption Settings)]
      _CorruptionColorOne("Color One", Color) = (1,0,0,1)
      _CorruptionColorTwo("Color Two", Color) = (0,1,0,1)

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

         #include "UnitySprites.cginc"
         #include "../DWD_ShaderFunctions.cginc"
         #include "../DWD_NoiseFunctions.cginc"

         fixed4 _RedColor, _GreenColor, _BlueColor;
         fixed4 _RedEdgeColor, _GreenEdgeColor, _BlueEdgeColor;
         float _RedStatic, _GreenStatic, _BlueStatic;
         float _RedScanlines, _GreenScanlines, _BlueScanlines;
         float _RedCorruption, _GreenCorruption, _BlueCorruption;

         sampler2D _Screen;
         fixed4 _ScanColorOne, _ScanColorTwo, _CorruptionColorOne, _CorruptionColorTwo, _StaticColor;
         float _LineTiling, _Scroll, _StaticIntensity, _Width, _Contrast;

         struct fragInput
         {
            float4 vertex   : SV_POSITION;
            fixed4 color    : COLOR;
            float3 coords : TEXCOORD0;
            UNITY_VERTEX_OUTPUT_STEREO
         };

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

         half4 frag(fragInput IN): SV_Target
         {
            half4 c = SampleSpriteTexture(IN.coords.xy);
            half3 invMask = half3(1,1,1) - c.rgb;
            half alpha = c.a;

            fixed redMask = alpha * invMask.g * invMask.b;
            fixed greenMask = alpha * c.g;
            fixed blueMask = alpha * c.b;

            fixed3 redScreen = GetScreenColor(_RedEdgeColor, _RedColor, c.r, redMask);
            fixed3 greenScreen = GetScreenColor(_GreenEdgeColor, _GreenColor, c.r, greenMask);
            fixed3 blueScreen = GetScreenColor(_BlueEdgeColor, _BlueColor, c.r, blueMask);

            fixed3 mix = redScreen + greenScreen + blueScreen;

            fixed scanlineUV = saturate((ZeroOneZero(frac((IN.coords.y + IN.coords.z) * _LineTiling)) - _Width) * _Contrast);
            fixed3 scanColor = lerp(_ScanColorOne.rgb, _ScanColorTwo.rgb, scanlineUV);
            fixed3 scannedScreen = ApplyOverlay(mix, scanColor);

            fixed scanMask = saturate((redMask * (invMask * _RedScanlines + _RedScanlines)) + (greenMask * _GreenScanlines) + (blueMask * _BlueScanlines));

            mix = lerp(mix, scannedScreen, scanMask);

            fixed4 fx = tex2D(_Screen,float2(IN.coords.z * -4.425, IN.coords.y)).rgba;
            fixed staticMask = saturate((redMask * (invMask * _RedStatic + _RedStatic)) + (greenMask * _GreenStatic) + blueMask * _BlueStatic);
            fixed s = Noise( float2(IN.coords.x * 1.03, IN.coords.z * (lerp(56.0, - 56.0, fx.r) * _StaticIntensity) ) * half2(256.0, 256.0) * _StaticColor.a);

            mix = lerp(mix, saturate(mix + (_StaticColor.rgb * s.xxx)), staticMask);

            fixed corruptionMask = saturate((redMask * (invMask * _RedCorruption + _RedCorruption)) + (greenMask * _GreenCorruption) + (blueMask * _BlueCorruption));
            fixed corruptionOne = corruptionMask * _CorruptionColorOne.a * fx.g;
            fixed corruptionTwo = corruptionMask * _CorruptionColorTwo.a * fx.b;
            fixed3 corruption = saturate((_CorruptionColorOne.rgb * corruptionOne.xxx) + (_CorruptionColorTwo.rgb * corruptionTwo.xxx));
            
            mix += corruption;

            return fixed4(mix * IN.color.rgb, alpha);
         }
            
         ENDCG        
      }
   }
}