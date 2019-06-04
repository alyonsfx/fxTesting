Shader "Custom/FX/Fresnel Texture Additive+"
{
 Properties 
    {
     _Color("Main Tint", Color) = (1,1,1,1)
     _MainTex ("Main Texture (RGB)", 2D) = "black" {}
     _MainMask ("Main Mask (Greyscale)", 2D) = "white" {}
     _Color2("Detail Tint", Color) = (1,1,1,1)
     _DetailTex ("Detail Texture (RGB)", 2D) = "black" {}
     _DetailMask ("Detail Mask (Greyscale)", 2D) = "white" {}
     _RimWidth("Rim Width", Float) = 0
     _RimPower("Rim Intensity", Float) = 1
    }

    SubShader 
 {
     Tags{"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
     LOD 100

     Pass
     {
         Blend SrcAlpha One
         ZWrite Off

            CGPROGRAM
         #pragma vertex vert
         #pragma fragment frag
         #pragma fragmentoption ARB_precision_hint_fastest
         #pragma target 2.0

         #include "UnityCG.cginc"
         #include "../Family.cginc"

         half4 _Color, _MainTex_ST, _Color2, _MainMask_ST, _DetailTex_ST, _DetailMask_ST;
         sampler2D _MainTex, _MainMask, _DetailTex, _DetailMask;
         half _RimWidth, _RimPower;

         struct v2f
         {
             half4 pos : SV_POSITION;
             half color : COLOR;
             half2 uv0 : TEXCOORD0;
             half2 uv1 : TEXCOORD1;
             half2 uv2 : TEXCOORD2;
             half2 uv3 : TEXCOORD3;
         };

         v2f vert (appdata_vnu v)
         {
             v2f o;
             o.pos = UnityObjectToClipPos(v.vertex);
             o.uv0 = TRANSFORM_TEX(v.texcoord0, _MainTex);
             o.uv1 = TRANSFORM_TEX(v.texcoord0, _MainMask);
             o.uv2 = TRANSFORM_TEX(v.texcoord0, _DetailTex);
             o.uv3 = TRANSFORM_TEX(v.texcoord0, _DetailMask);
             o.color = fresnel(v.vertex, v.normal);
             return o;
         }

         half4 frag (v2f i) : SV_Target
         {           
             half4 col = tex2D(_MainTex, i.uv0) * _Color * Luminance(tex2D(_MainMask, i.uv1));
             half4 col2 = tex2D(_DetailTex, i.uv2) * _Color2 * Luminance(tex2D(_DetailMask, i.uv3));
             col += col2;
             col *= fresnelFalloff(i.color, _RimWidth, _RimPower);
             return col;
         }
            ENDCG           
        }
    } 
    FallBack "Mobile/Particles/Additive"
}
