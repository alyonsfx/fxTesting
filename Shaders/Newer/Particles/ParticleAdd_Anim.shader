// A mobile version of the built in Unity Animated Addative shader
// This uses custom vertex info from particle systems to blend between 2 frames
// Also has a tint color

Shader "Mobile/Particles/Anim Additive"
{
    Properties
    {
        _TintColor ("Tint Color", Color) = (0.5, 0.5, 0.5, 0.5)
        _MainTex ("Particle Texture", 2D) = "white" { }
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" }

        Pass
        {
            Blend SrcAlpha One
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "../N3twork.cginc"

            half4 _TintColor, _MainTex_ST;
            sampler2D _MainTex;
            
            struct appdata_t
            {
                float4 vertex: POSITION;
                half4 color: COLOR;
                half4 texcoord0: TEXCOORD0;
                half texcoordBlend: TEXCOORD1;
            };

            struct v2f
            {
                float4 vertex: SV_POSITION;
                half4 color: COLOR;
                half2 uv0: TEXCOORD0;
                half2 uv1: TEXCOORD1;
                half blend: TEXCOORD2;
            };
            

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.color * _TintColor * 2;
                o.uv0 = TRANSFORM_TEX(v.texcoord0.xy, _MainTex);
                o.uv1 = TRANSFORM_TEX(v.texcoord0.zw, _MainTex);
                o.blend = v.texcoordBlend;
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                half4 colA = tex2D(_MainTex, i.uv0);
                half4 colB = tex2D(_MainTex, i.uv1);
                return lerp(colA, colB, i.blend) * i.color;
            }
            ENDCG
            
        }
    }
}
