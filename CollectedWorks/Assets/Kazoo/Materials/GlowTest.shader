Shader "Custom/Glow Test"
{
    Properties
    {
        _TintColor ("Tint Color", Color) = (0.5, 0.5, 0.5, 0.5)
        _MainTex ("Particle Texture", 2D) = "white" { }
        _LUT ("Look Up Table", 2D) = "white" { }
        _Speed ("Color Speed", Float) = 1
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" }

        Pass
        {
            Blend SrcAlpha One
            ZWrite Off
            Cull Off
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"

            half4 _TintColor, _MainTex_ST;
            sampler2D _MainTex, _LUT;
            half _Speed;
            
            struct appdata
            {
                float4 vertex: POSITION;
                half2 texcoord: TEXCOORD0;
                half4 color: COLOR;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                half2 uv: TEXCOORD0;
                half4 color: COLOR;
                half offset : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.color * _TintColor * 2;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.offset = _Time.y * _Speed;
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                half2 tex = tex2D(_MainTex, i.uv).rg;
                float temp = frac(tex.g + i.offset);
                half4 col = tex2D(_LUT, float2(temp, 0.5));
                col.a = tex.r;
                return col;
            }
            ENDCG
            
        }
    }
}