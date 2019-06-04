Shader "Debug/Worldspace Checkerboard"
{
 Properties
 {
    _Color1 ("Color 1 (RGB)", Color) = (1,1,1,1) 
    _Color2 ("Color 2 (RGB)", Color) = (0.5,0.5,0.5,1)
    _BaseScale ("Tiling (XYZ)", Vector) = (1,1,1,0)
    _Offset ("Offset (XYZ)", Vector) = (0,0,0,0)
 }
 SubShader
 {
     Tags { "RenderType" = "Opaque" }

     Pass
     {
         CGPROGRAM
         #pragma vertex vert
         #pragma fragment frag
         #pragma fragmentoption ARB_precision_hint_fastest
         #pragma target 2.0

         #include "UnityCG.cginc"

        half3 _BaseScale, _Offset;
        half4 _Color1, _Color2;
         
        struct appdata
        {
            half4 vertex : POSITION;
        };

        struct v2f
        {
            half4 pos : POSITION;
            half3 uv : TEXCOORD0;
        };

        v2f vert (appdata v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = mul(unity_ObjectToWorld, v.vertex);
            o.uv *= _BaseScale;
            o.uv += _Offset;
            return o;
        }

        half4 frag (v2f i) : SV_Target
        {
            half3 worldPos = floor(i.uv + half3(0.001, 0.001, 0.001));
            int sum = worldPos.x + worldPos.y + worldPos.z;
            half mod = abs(fmod(sum, 2.0));
            half4 col = lerp(_Color1, _Color2, mod);
            col.a = 1;
            return col;
        }
        ENDCG
     }
 }
}