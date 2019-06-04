Shader "Mino/Anime Background Blend"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
        _Blend ("Blend", Range(0.00, 1.00)) = 0.00
        [Space(10)]
        _TopN ("Top Point - Night", Range(0.00, 1.00)) = 1.00
        _ColorTopN ("Top - Night", Color) = (1, 1, 1, 1)
        _MiddleN ("Mid Point - Night", Range(0.00, 1.00)) = 0.50
        _ColorMidN ("Middle - Night", Color) = (1, 1, 1, 1)
        _BottomN ("Bottom Point - Night", Range(0.00, 1.00)) = 0.00
        _ColorBotN ("Bottom - Night", Color) = (1, 1, 1, 1)
        [Space(10)]
        _TopD ("Top Point - Day", Range(0.00, 1.00)) = 1.00
        _ColorTopD ("Top - Day", Color) = (1, 1, 1, 1)
        _MiddleD ("Mid Point - Day", Range(0.00, 1.00)) = 0.50
        _ColorMidD ("Middle - Day", Color) = (1, 1, 1, 1)
        _BottomD ("Bottom Point - Day", Range(0.00, 1.00)) = 0.00
        _ColorBotD ("Bottom - Day", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "False" }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma target 2.0

            #include "UnityCG.cginc"

            struct appdata
            {
                half4 vertex: POSITION;
                half2 texcoord: TEXCOORD0;
            };

            struct v2f
            {
                half4 pos: SV_POSITION;
                half texcoord: TEXCOORD0;
            };

            half4  _ColorTopN, _ColorMidN, _ColorBotN, _ColorTopD, _ColorMidD, _ColorBotD;
            half _Blend, _TopN, _MiddleN, _BottomN, _TopD, _MiddleD, _BottomD;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                half t = cos(_Time.y * _Blend) * 0.5 + 0.5;
                o.texcoord = v.texcoord.y;
                return o;
            }

            half4 frag(v2f i): COLOR
            {
                float nightPct = min(max(i.texcoord - _BottomN, 0) / (_TopN - _BottomN), 1);
                float4 nightColor = _ColorBotN + (_ColorMidN - _ColorBotN) * (min(nightPct, _MiddleN) / _MiddleN) + (_ColorTopN - _ColorMidN) * (max(nightPct - _MiddleN, 0) / (1 - _MiddleN));

                float dayPct = min(max(i.texcoord - _BottomD, 0) / (_TopD - _BottomD), 1);
                float4 dayColor = _ColorBotD + (_ColorMidD - _ColorBotD) * (min(dayPct, _MiddleD) / _MiddleD) + (_ColorTopD - _ColorMidD) * (max(dayPct - _MiddleD, 0) / (1 - _MiddleD));

                float4 col = lerp(nightColor, dayColor, _Blend);
                UNITY_OPAQUE_ALPHA(col.a);
                return col;
            }
            
            ENDCG
            
        }
    }
}
