Shader "Unlit/Fire"
{
    Properties
    {
        _TintColor ("Tint Color", Color) = (0.5, 0.5, 0.5, 0.5)
		[Header(UV Distortion X(R)  UV Distortion Y(G) Erosion(B) Mask(A))]
        _MainTex ("", 2D) = "white" { }
        _ScrollX ("Scroll Speed X", Float) = 0.2
        _ScrollY ("Scroll Speed Y", Float) = -0.5
        _DistortionAmount ("UV Distortion Strength", Float) = 0.05
        _LUT ("Lookup Table", 2D) = "white" { }
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
            half _ScrollX, _ScrollY, _DistortionAmount;

            half2 scrollUVs(half2 uv, half2 speed)
	        {
		        if (speed.x != 0 || speed.y != 0)
		        {
			        speed *= _Time.y;
			        uv += speed;
		        }
		        return uv;
	        }

            struct appdata
            {
                float4 vertex: POSITION;
                half2 texcoord: TEXCOORD0;
                half4 color: COLOR;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                half4 uv: TEXCOORD0;
                half4 color: COLOR;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.color * _TintColor * 2;
                half2 baseUV = TRANSFORM_TEX(v.texcoord, _MainTex);
                half2 newUVs = scrollUVs(baseUV,half2(_ScrollX, _ScrollY));
                o.uv = half4(baseUV, newUVs);
                return o;
            }

            half4 frag(v2f i): SV_Target
            {
                half2 texScroll= tex2D(_MainTex, i.uv.zw).rg;
                half2 offsetUVs = texScroll;
                offsetUVs *= 2;
                offsetUVs - 1;
                offsetUVs *= _DistortionAmount;
                offsetUVs += i.uv.xy;

                half temp = tex2D(_MainTex, offsetUVs).b;
                temp *= texScroll.x+0.3;
                temp *= texScroll.y+0.5;
                temp *= tex2D(_MainTex, i.uv.xy).b;
                half3 col = tex2D(_LUT, half2(temp, 0.1f)).rgb;

                half4 final = half4(col, temp) * i.color;
                return final;
            }
            ENDCG

        }
    }
}
