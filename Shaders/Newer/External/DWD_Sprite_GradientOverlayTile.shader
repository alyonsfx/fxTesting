//© Dicewrench Designs LLC 2020
//All Rights Reserved, used with permission
//Last Owned by: Allen White (allen@dicewrenchdesigns.com)


Shader "Custom/DWD/Sprites/Gradient w Overlayed Tile"
{
   Properties
   {
      [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
      _Color ("Tint", Color) = (1, 1, 1, 1)

      [Header(Gradient Colors)]
      _GradOne ("Gradient One", Color) = (1,0,0,1)
      _GradTwo ("Gradient Two", Color) = (0,1,0,1)
      _GradThree ("Gradient Three", Color) = (0,0,1,1)

      [Header(Gradient Settings)]
      _Size("World Unit Size", Float) = 10.0
      _Angle("Angle", Range(0,360)) = 0.0
      _Offset ("Offset", Float) = 0.0
      _Width("Mid Width", Float) = 0.0
      _Pow ("Pow", Float) = 0.5
      _Boost ("Boost", Float) = 1.0
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

         half4 _GradOne, _GradTwo, _GradThree;
         float _Size, _Angle, _Offset, _Pow, _Boost, _Width;

         struct fragInput
         {
            float4 vertex   : SV_POSITION;
            fixed4 color    : COLOR;
            float4 coords : TEXCOORD0;
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

            float3 worldPos = mul(unity_ObjectToWorld, IN.vertex).xyz;
            OUT.coords.zw = worldPos.xy / _Size.xx;
            OUT.color = IN.color * _Color;

            #ifdef PIXELSNAP_ON
               OUT.vertex = UnityPixelSnap (OUT.vertex);
            #endif

            return OUT;
         }


         half4 frag(fragInput IN): SV_Target
         {
            float top = saturate(ComputePivotRotation(IN.coords.zw, _Angle, float2(_Offset,_Offset))).x;
            float topWidth = saturate(top - _Width);
            float bottomWidth = saturate((1.0 - top) - _Width);

            float mid = 1.0 - saturate(topWidth + bottomWidth);
            float grad = saturate(pow(top, _Pow) * _Boost);
            mid = saturate(pow(mid, _Pow) * _Boost);

            half4 c = SampleSpriteTexture(IN.coords.xy);
            
            half4 gradCol = lerp(_GradOne, _GradThree, grad);
            gradCol = lerp(gradCol, _GradTwo, mid);

            gradCol.rgb  = ApplyOverlay(gradCol.rgb, c.rgb);

            gradCol *= IN.color;

            return gradCol;
         }
            
         ENDCG        
      }
   }
}