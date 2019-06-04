// No realtime light
// Multiplies light probe data to fake shading
// Addes specular highlights per vert
// Addes tinted glow based on texture Alpha
Shader "Rocket Boy/Environment/Diffuse - Probe Lighting"
{
 Properties
 {
     _MainTex("Texture (RGB) Glow (A)", 2D) = "grey" {}
     _DiffusePower("Diffuse Lighting Intensity", Range(0.0, 1.0)) = 1.0
 }

 SubShader
 {
     Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
     Lighting Off
     Pass
     {
         Name "BASE"
         Tags { "LightMode" = "ForwardBase" }
         Blend SrcAlpha OneMinusSrcAlpha

         CGPROGRAM
         #pragma fragment frag
         #pragma vertex vert
         #pragma fragmentoption ARB_precision_hint_fastest
         #pragma target 2.0
         
         #include "UnityCG.cginc"
         #include "RocketBoy.cginc"

         uniform sampler2D _MainTex;
         fixed4 _MainTex_ST;
         fixed _DiffusePower;

         struct appdata
         {
             fixed4 vertex : POSITION;
             fixed4 texcoord : TEXCOORD0;
             fixed3 normal : NORMAL;
         };
         
         struct v2f
         {
             fixed4 pos : SV_POSITION;
             fixed2 uv : TEXCOORD0;
             fixed3 diffuse : COLOR;
         };
         
         v2f vert(appdata v)
         {
             v2f o;
             o.pos = UnityObjectToClipPos(v.vertex );
             o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
             // lighting
             o.diffuse = diffuse(v.normal);
             return o;
         }
         
         fixed4 frag(v2f i) : SV_Target
         {
             fixed4 tex = tex2D(_MainTex, i.uv);
             tex.xyz *= lerp(fixed3(1, 1, 1), i.diffuse, _DiffusePower);
             tex.a = 1;
             return tex;
         }
         ENDCG
     }
 }
 Fallback "Mobile/VertexLit"
}