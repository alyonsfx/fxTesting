Shader "Mobile/Particles/Anim Additive"
{
    Properties
    {
        _TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
        _MainTex ("Particle Texture", 2D) = "white" {}
    }

    Category
    {
        SubShader
        {
            Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }

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
                #include "../Family.cginc"

                half4 _TintColor, _MainTex_ST;
                sampler2D _MainTex;
    			
    			struct appdata_t {
    				float4 vertex : POSITION;
    				half4 color : COLOR;
    				half4 texcoords : TEXCOORD0;
    				half texcoordBlend : TEXCOORD1;
    			};

    			struct v2f {
    				float4 vertex : SV_POSITION;
    				half4 color : COLOR;
    				half2 texcoord : TEXCOORD0;
    				half2 texcoord2 : TEXCOORD1;
    				half blend : TEXCOORD2;
    			};         

    			v2f vert (appdata_t v)
    			{
    				v2f o;
    				o.vertex = UnityObjectToClipPos(v.vertex);
                    o.color = v.color * _TintColor * 2;
    				o.texcoord = TRANSFORM_TEX(v.texcoords.xy,_MainTex);
    				o.texcoord2 = TRANSFORM_TEX(v.texcoords.zw,_MainTex);
    				o.blend = v.texcoordBlend;
    				return o;
    			}
    			
    			half4 frag (v2f i) : SV_Target
    			{
    				half4 colA = tex2D(_MainTex, i.texcoord);
    				half4 colB = tex2D(_MainTex, i.texcoord2);
    				return i.color * lerp(colA, colB, i.blend);
    			}
    			ENDCG 
    		}
    	}	
    }
}
