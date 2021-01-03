// Based on Mobile/Particles/Additive
// Adds tint color and double value

Shader "Custom/Particles/Additive Scroll"
{
    Properties
    {
        _TintColor ("Tint Color", Color) = (0.5, 0.5, 0.5, 0.5)
        _MainTex ("Particle Texture", 2D) = "white" { }
        _SpeedX ("Scroll Speed X", Float) = 0
        _SpeedY ("Scroll Speed Y", Float) = 0
    }

    Category
    {
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
                #pragma fragmentoption ARB_precision_hint_fastest
                #pragma target 2.0

                #include "UnityCG.cginc"

                half4 _TintColor, _MainTex_ST;
                sampler2D _MainTex;
                half _SpeedX, _SpeedY;
                
                struct appdata
                {
                    float4 vertex: POSITION;
                    half4 texcoord: TEXCOORD0;
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
                    half2 temp = v.texcoord;
                    temp += half2(_SpeedX, _SpeedY) * _Time.y;
                    o.uv = TRANSFORM_TEX(temp, _MainTex);
                    return o;
                }
                
                half4 frag(v2f i): SV_Target
                {
                    return tex2D(_MainTex, i.uv) * i.color;
                }
                ENDCG
                
            }
        }
    }
}