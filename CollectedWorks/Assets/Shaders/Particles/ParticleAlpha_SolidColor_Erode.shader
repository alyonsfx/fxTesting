Shader "Custom/Particles/Custom Data/Alpha Blended (1Channel - Errosion)"
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
            Blend SrcAlpha OneMinusSrcAlpha
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


            struct appdata
            {
                float4 vertex: POSITION;
                half3 texcoord0: TEXCOORD0;
                half4 color: COLOR;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                half2 uv: TEXCOORD0;
                half4 color: COLOR;
                half errosion: TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.color * _TintColor * 2;
                o.uv = TRANSFORM_TEX(v.texcoord0.xy, _MainTex);
                o.errosion = v.texcoord0.z;
                return o;
            }

            half4 frag(v2f i): SV_Target
            {
                half4 col = i.color;
                col.a *= erode(tex2D(_MainTex, i.uv).r, 1 - i.errosion);
                return col;
            }
            ENDCG

        }
    }
}
