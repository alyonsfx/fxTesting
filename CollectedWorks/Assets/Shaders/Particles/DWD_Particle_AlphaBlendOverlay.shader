//© Dicewrench Designs LLC 2020
//All Rights Reserved, used with permission
//Last Owned by: Allen White (allen@dicewrenchdesigns.com)


Shader "Custom/DWD/Particles/Alpha Ovleray"
{
   Properties
   {
   _TintColor ("Tint Color", Color) = (0.5, 0.5, 0.5, 0.5)
   _MainTex ("Overlay Texture", 2D) = "white" { }
   }

   SubShader
   {
      Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" }

      Pass
      {
         Blend SrcAlpha OneMinusSrcAlpha
         Cull Off
         ZWrite Off
            
         CGPROGRAM
            
         #pragma vertex vert
         #pragma fragment frag
         #pragma target 2.0

         #include "UnityCG.cginc"
         #include "Assets/Mino/Art/Shaders/DWD_ShaderFunctions.cginc"

         half4 _TintColor, _MainTex_ST;
         sampler2D _MainTex;
            
         struct appdata
         {
            float4 vertex: POSITION;
            half2 texcoord0: TEXCOORD0;
            half4 color: COLOR;
         };

         struct v2f
         {
            float4 pos: SV_POSITION;
            half2 uv: TEXCOORD0;
            half4 color: COLOR;
         };

         v2f vert(appdata v)
         {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.color = (v.color * _TintColor * 2);
            o.uv = TRANSFORM_TEX(v.texcoord0, _MainTex);
            return o;
         }
            
         half4 frag(v2f i): SV_Target
         {        
            half4 t = tex2D(_MainTex, i.uv);
            half4 col = i.color;
            col.a *= t.a;
            col.rgb = ApplyOverlay( t.rgb, col.rgb);

            return saturate(col);
         }
         ENDCG           
      }
   }
}