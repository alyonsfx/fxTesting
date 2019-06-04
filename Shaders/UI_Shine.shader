Shader "UI/UI Sheen"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
        [PerRendererData] _SheenTex ("Sheen Texture (RGB)", 2D) = "black" { }
        _Color ("Tint", Color) = (1, 1, 1, 1)
        _SheenTime ("Seconds to wipe", Float) = 1.5
        _SheenDelay ("Seconds to rest", Float) = 3
        [MaterialToggle] _Individual ("Individual", Float) = 0
        
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        _ColorMask ("Color Mask", Float) = 15
        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "True" }
        
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }
        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "UnityUI.cginc"
            #pragma multi_compile __ UNITY_UI_ALPHACLIP
            
            struct appdata_t
            {
                half4 vertex: POSITION;
                half4 color: COLOR;
                half2 texcoord: TEXCOORD0;
                half2 texcoord2: TEXCOORD1;
            };
            struct v2f
            {
                half4 vertex: SV_POSITION;
                half4 color: COLOR;
                half2 texcoord: TEXCOORD0;
                half2 texcoord2: TEXCOORD1;
                half4 worldPosition: TEXCOORD2;
            };
            
            half4 _Color, _TextureSampleAdd, _ClipRect, _SheenTex_ST;
            half _SheenTime, _SheenDelay, _Individual;

            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.worldPosition = IN.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);
                OUT.texcoord = IN.texcoord;
                half aspect = 1;
                half2 progressUV;
                half preDelay = 0;
                half boost = 1;
                if (_Individual == 1)
                {
                    //Use the UVs calculated in UISheen.cs
                    progressUV = IN.texcoord2;
                    //Extract the onscreen dimensions
                    half4 centerPos = mul(unity_ObjectToWorld, half4(0, 0, 0, 1));
                    half4 cornerPos = mul(unity_ObjectToWorld, half4(1, 1, 1, 1));
                    half4 objParams = (cornerPos - centerPos);
                    aspect = objParams.y / objParams.x;
                    preDelay = 0.5;
                    boost = 2;
                }
                else
                {
                    //Screen space uv coordinates
                    progressUV = (OUT.vertex.xy / OUT.vertex.w + half2(1, 1)) * 0.5;
                    aspect = unity_OrthoParams.y / unity_OrthoParams.x;
                }
                //Make our sheen tex square
                progressUV.y *= aspect;
                //The height of the textxure + the height of the screen. This is so we start AND end off screen.
                half dist = (aspect + 1.0);
                //units per second
                half speed = dist / _SheenTime;
                half delay = speed * _SheenDelay;
                //Loop
                half progress = (_Time.y * speed) % (dist + delay);
                //make the sweep faster
                progress *= boost;
                //Start above screen
                progress -= aspect;
                //Fudge
                progress -= preDelay;
                progressUV.y += progress;
                OUT.texcoord2 = progressUV;
                
                #ifdef UNITY_HALF_TEXEL_OFFSET
                    OUT.vertex.xy += (_ScreenParams.zw - 1.0) * half2(-1, 1);
                #endif
                
                OUT.color = IN.color * _Color;
                return OUT;
            }
            sampler2D _MainTex, _SheenTex;
            half4 frag(v2f IN): SV_Target
            {
                half4 color = tex2D(_MainTex, IN.texcoord);
                half4 sheen = tex2D(_SheenTex, IN.texcoord2);
                sheen *= color.a;
                sheen.a = 0;
                color += sheen * color.a;
                color = (color + _TextureSampleAdd) * IN.color;
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                
                #ifdef UNITY_UI_ALPHACLIP
                    clip(color.a - 0.001);
                #endif
                return color;
            }
            ENDCG
            
        }
    }
}