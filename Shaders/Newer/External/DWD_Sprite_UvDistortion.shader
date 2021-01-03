//© Dicewrench Designs LLC 2020
//All Rights Reserved, used with permission
//Last Owned by: Allen White (allen@dicewrenchdesigns.com)


Shader "Custom/DWD/Sprites/UV Distortion"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
        _Color ("Tint", Color) = (1, 1, 1, 1)

        [Header(Distortion Scrolling)]
        _X("X Scroll Rate", Float) = 0.0
        _Y("Y Scroll Rate", Float) = 0.2

        [Header(UV Distortion Texture Settings)]
        _UV ("Distortion Tex", 2D) = "black" {}
        [Space]
        _Red("Red Channel Distortion Intensity", Range(0,1)) = 0.0
        _Green("Green Channel Distortion Intensity", Range(0,1)) = 0.0
        _Blue("Blue Channel Distortion Intensity", Range(0,1)) = 0.0
        _Alpha("Alpha Channel Distortion Intensity", Range(0,1)) = 0.0
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"
            "CanUseSpriteAtlas" = "True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_instancing
            #pragma multi_compile _ PIXELSNAP_ON
            #pragma multi_compile _ ETC1_EXTERNAL_ALPHA

            #include "UnitySprites.cginc"
            #include "../DWD_ShaderFunctions.cginc"
            #include "../DWD_NoiseFunctions.cginc"

            sampler2D _UV;
            uniform float4 _UV_ST;
            float _Red, _Green, _Blue, _Alpha, _X, _Y;

            struct vert2frag
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                float4 coords : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            vert2frag vert(appdata_t IN)
            {
                vert2frag OUT;

                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                OUT.vertex = UnityFlipSprite(IN.vertex, _Flip);
                OUT.vertex = UnityObjectToClipPos(OUT.vertex);
                OUT.coords.xy = IN.texcoord.xy;
                OUT.coords.zw = IN.texcoord.xy * _UV_ST.xy + _UV_ST.zw;
                float t = _Time.x;
                OUT.coords.z += t * _X;
                OUT.coords.w += t * _Y;
                OUT.color = IN.color * _RendererColor;

                #ifdef PIXELSNAP_ON
               OUT.vertex = UnityPixelSnap (OUT.vertex);
                #endif

                return OUT;
            }

            half4 frag(vert2frag IN): SV_Target
            {
                float4 d = tex2D(_UV, IN.coords.zw);
                float2 uv = IN.coords.xy;
                uv.x -= ((d.r * 2.0 - 1.0) * _Red);
                uv.x -= ((d.b * 2.0 - 1.0) * _Blue);
                uv.y -= ((d.g * 2.0 - 1.0) * _Green);
                uv.y -= ((d.a * 2.0 - 1.0) * _Alpha);
                half4 c = SampleSpriteTexture(uv) * IN.color;
                c.rgb *= c.a;
                return c;
            }
            ENDCG
        }
    }
}