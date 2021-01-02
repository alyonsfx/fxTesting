Shader "Custom/Particles/Alpha Blended (Solid Color Channel Pack)"
{
    Properties
    {
        _TintColor ("Tint Color", Color) = (0.5, 0.5, 0.5, 0.5)
        _AddColor ("Additive Color", Color) = (1, 1, 1, 1)
        _MainTex ("Particle Mask (R) Add Color (G)", 2D) = "white" { }
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

            half4 _TintColor, _AddColor, _MainTex_ST;
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
                o.color = v.color * _TintColor * 2;
                o.uv.xy = TRANSFORM_TEX(v.texcoord0.xy, _MainTex);
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                half2 tex = tex2D(_MainTex, i.uv).rg;
                half4 col = i.color;
                col.rgb = lerp(col.rgb, col.rgb + _AddColor.rgb, tex.g * _AddColor.a);
                col.a *= tex.r;
                return col;
            }
            ENDCG
            
        }
    }
}