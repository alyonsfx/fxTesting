Shader "Mino/Royale/Screen Space Highlight"
{
    Properties
    {
        _Boost ("Highlight Intensity", Range(0.00, 1.00)) = 0.2
        _PulseOffset ("Highlight Position", Range(-1.00, 2.00)) = 0
        _Range ("Highlight Range", Float) = 2
        _MainTex ("Particle Texture", 2D) = "white" { }
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
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma target 2.0

            #include "UnityCG.cginc"

            half _Boost, _PulseOffset, _Range;
            half4 _MainTex_ST;
            sampler2D _MainTex;
            
            struct appdata
            {
                float4 vertex: POSITION;
                half4 texcoord0: TEXCOORD0;
                half4 color: COLOR;
                half1 texcoord1: TEXCOORD1;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                half2 uv0: TEXCOORD0;
                half uv1: TEXCOORD1;
                half4 color: COLOR;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                o.uv0 = TRANSFORM_TEX(v.texcoord0.xy, _MainTex);
                float4 temp = UnityObjectToClipPos(half3(v.texcoord0.zw, v.texcoord1));
                o.uv1 = ComputeScreenPos(temp).y;
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                half dist = abs(i.uv1 - _PulseOffset);
                dist = 1 - clamp(dist, 0, 1);
                dist = clamp(pow(dist, _Range), 0, 1);
                half4 col = i.color + lerp(0, _Boost, dist);
                return tex2D(_MainTex, i.uv0) * col ;
            }
            ENDCG
            
        }
    }
}