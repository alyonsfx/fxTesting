Shader "Custom/Particles/Multiply (Solid Color)"
{
    Properties
    {
        _TintColor ("Tint Color", Color) = (0.5, 0.5, 0.5, 0.5)
        _MainTex ("Particle Mask (R)", 2D) = "white" { }
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" }

        Pass
        {
            Blend Zero SrcColor
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"

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
                o.color = v.color * _TintColor;
                o.uv = TRANSFORM_TEX(v.texcoord0, _MainTex);
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                return lerp(half4(1, 1, 1, 1), i.color, tex2D(_MainTex, i.uv).r);
            }
            ENDCG
            
        }
    }
}