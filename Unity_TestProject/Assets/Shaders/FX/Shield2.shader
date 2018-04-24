Shader "Custom/FX/Shield"
{
 Properties 
    {
     _Color("Color", Color) = (0,0,1,1)
     _DepthColor("Depth Color", Color) = (1,0,0,1)
     _Scroll("Scroll Speed - Main (XY) Mask (ZW)", Vector) = (0,-0.1,0,-0.4)
     _MainTex ("Base (RGB)", 2D) = "white" {}
     _MaskTex ("Mask (Greyscale)", 2D) = "white" {}
     _RimWidth("Rim Width", Float) = 1.5
     _RimPower("Rim Intensity", Float) = 0.5
     _Emmission("Rim Glow", Float) = 0.7
     _Dist("Depth Distance", Float) = 0.15
    }

    SubShader 
 {
     Tags{"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}

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
     
         half4 _Color, _DepthColor, _MaskTex_ST, _MainTex_ST, _Scroll;
         uniform sampler2D _MainTex, _MaskTex;
         half _RimPower, _RimWidth, _Emmission, _Dist;
 
         v2f_vuuc vert (appdata_vnu v)
         {
            // v2f_vuuc o;
            // o.pos = UnityObjectToClipPos(v.vertex);
            // half3 worldPos = mul(unity_ObjectToWorld, v.vertex);
            // o.uv0 = TRANSFORM_TEX(v.texcoord, _MainTex);
            // o.uv0 = scrollUVs(_Scroll.xy, o.uv0);
            // o.uv1 = TRANSFORM_TEX(fixed2(v.vertex.x, worldPos.y), _MaskTex);
            // o.uv1 = scrollUVs(_Scroll.zw, o.uv1);
            // o.color = fresnel(v.vertex, v.normal, _RimWidth, _RimPower);
            // return o;
            v2f_vuuc o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.color = fresnel(v.vertex,v.normal).xxxx;
            o.uv0 = half2(scrollUVs(v.texcoord0,_Scroll.xy));
            o.uv1 = half2(scrollUVs(v.texcoord0,_Scroll.zw));
            return o;

         }

         half4 frag (v2f_vuuc i) : SV_Target
         {
             half4 main = tex2D(_MainTex, i.uv0);
             half4 mask = Luminance(tex2D(_MaskTex, i.uv1));
             half4 col = main * mask * _Color * i.color;
             return col;
         }
            ENDCG           
        }
    }
}