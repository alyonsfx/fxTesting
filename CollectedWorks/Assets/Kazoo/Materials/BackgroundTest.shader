Shader "Unlit/Background Test"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _MaskColor1 ("Mask Color 1", Color) = (0, 0, 0, 0)
        _MaskColor2 ("Mask Color 2", Color) = (0, 0, 0, 0)
        _Speed ("Speed", Float) = 0.1
        _VinColor ("Edge Color", Color) = (0, 0, 0, 0)
        _Radius ("Radius", Float) = 0.1
        _Roundness ("Roundness",  Range (0.00, 1.00)) = 0.1
        _Falloff ("Falloff", Float) = 0.1
        _Intensity ("Intensity", Range (0.00, 1.00)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 screen : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _BaseColor, _MaskColor1, _MaskColor2, _VinColor;
            half _Speed, _Radius,_Intensity, _Falloff, _Roundness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screen = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half aspectRatio = (_ScreenParams.x/_ScreenParams.y);
                half2 screenPos = i.screen.xy / i.screen.w;


                screenPos.x = lerp(screenPos.x, screenPos * aspectRatio, _Roundness);
                half hCenter = lerp(0.5, 0.5 * aspectRatio, _Roundness);
                half dist = distance(screenPos, half2(hCenter,0.5)) / _Radius;
                dist = pow(dist, _Falloff);
                dist = saturate(dist);

                fixed2 tex = tex2D(_MainTex, i.uv).rg;
                half4 col =_BaseColor;
                half mask = frac(tex.y + (_Time.y * _Speed));
                mask *= 2;
                mask -= 1;
                mask = abs(mask);
                mask += col.a;
                half4 temp = lerp(_MaskColor1, _MaskColor2, mask);
                col.rgb = lerp(col.rgb, temp, saturate(tex.x * temp.a));
                col.rgb= lerp(col.rgb, _VinColor.rgb, dist * _Intensity);
                return col;
            }
            ENDCG
        }
    }
}
