// Fresnel
// these are slightly faster, more math is done in Vert
half fresnel (half4 vertex, half3 normal, half width, half intensity)
{
 half3 viewDir = normalize(ObjSpaceViewDir(vertex));
 half dotProduct = 1 - clamp(pow(dot(viewDir, normal), width),0,1);
 return clamp(intensity * dotProduct,0,1);
}

half4 fresnel (half3 viewDir, half3 normal, half width, half intensity)
{
 half dotProduct = 1 - clamp(pow(dot(viewDir, normal), width),0,1);
 dotProduct *= intensity;
 return clamp(dotProduct,0,1);
}

// these are smoother, require fresnelFalloff in Frag
half fresnel (half4 vertex, half3 normal)
{
 half3 viewDir = normalize(ObjSpaceViewDir(vertex));
 return dot(viewDir, normal);
}

half4 fresnel (half3 viewDir, half3 normal)
{
 return dot(viewDir, normal);
}

half fresnelFalloff (half mask, half width, half intensity)
{
 return 1 - clamp(pow(mask, width) * intensity, 0, 1);
}

half fresnelFalloff (half mask, half width, half intensity, half offset)
{
 half temp = pow(mask, width) * intensity;
 return 1 - clamp(temp - offset, 0 , 1);
}

// Directional Hightlight
half rimLight (half3 normal, half3 direction, half width, half intensity)
{
 half3 normDir = normalize(UnityObjectToWorldNormal(normal));
 normDir = pow(dot( direction.xyz,normDir), width) * intensity;
 return clamp(normDir,0,1);
}

half rimLight (half3 normal, half3 direction)
{
 half3 normDir = normalize(UnityObjectToWorldNormal(normal));
 return dot( direction.xyz,normDir);
}

// adjust vertex position based off of distance from center
half3 jitter (half distance, half speed, half mask, half3 normal, half3 position)
{
 if (distance != 0.0 && speed != 0)
 {
     half3 ripple =  sin(mask * normal * speed * _Time.y * 10);
     ripple = position + (ripple * distance * 0.05);
     return ripple;
 }
 return position;
}

half3 jitter (half distance, half speed, half mask, half3 normal, half4 position)
{
 if (distance != 0.0 && speed != 0)
 {
     half3 ripple =  sin(mask * normal * speed * _Time.y * 10);
     ripple = position.xyz + (ripple * distance * 0.05);
     return ripple;
 }
 return position;
}

// light probe based diffuse lighting
fixed3 fakeDiffuse (fixed3 normal)
{
 fixed3 worldNormal = UnityObjectToWorldNormal(normal);
 fixed3 shl = ShadeSH9(fixed4(worldNormal, 1));
 shl = clamp(shl,0,1);
 return shl;
}

// light probe based diffuse lighting and specular highlights
void fakeDiffuseSpec (fixed3 normal, fixed4 vertex, fixed rolloff, fixed intensity, inout fixed3 diffuse, inout fixed3 spec)
{
 fixed3 worldNormal = UnityObjectToWorldNormal(normal);
 fixed3 shl = ShadeSH9(fixed4(worldNormal, 1));
 diffuse = clamp(shl,0,1);

 fixed3 worldV = normalize(-WorldSpaceViewDir(vertex));
 fixed3 refl = reflect(worldV, worldNormal);
 fixed3 worldLightDir = _WorldSpaceLightPos0;
 spec = clamp(dot(worldLightDir, refl),0,1);
 spec = diffuse * pow(spec, rolloff) * intensity;
 clamp(spec,0,1);
}

//combines two normal maps
half3 combineNormalMaps (half3 base, half3 detail)
{
 base.z += 1.0;
 detail.xy *= -1.0;
 base *= dot(base, detail) / base.z - detail;
 return base;
}

// scroll UVs
half2 scrollUVs (half2 uv, half2 speed)
{
 if (speed.x != 0 || speed.y != 0)
 {
     speed *= _Time.y;
     uv += speed;
 }
 return uv;
}

//Normalized Z World Position
half2 worldPosZ (half4 pos, half offset)
{
 half zPos = mul (unity_WorldToObject, pos).z;
 zPos *= offset * 0.1;
 zPos += 0.5;
 return zPos;
}

//Convert RBG to HSV
half3 rgb2hsv (half3 c)
{
 half4 K = half4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
 half4 p = lerp(half4(c.bg, K.wz), half4(c.gb, K.xy), step(c.b, c.g));
 half4 q = lerp(half4(p.xyw, c.r), half4(c.r, p.yzx), step(p.x, c.r));

 half d = q.x - min(q.w, q.y);
 half e = 1.0e-10;
 return half3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

//Covert HSV to RGB
half3 hsv2rgb (half3 c)
{
 c = half3(c.x, clamp(c.yz, 0.0, 1.0));
 half4 K = half4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
 half3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
 return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Hue shift
void hueShift (inout half4 c, half shift)
{
 if (shift != 0)
 {
     c.xyz = rgb2hsv(c.xyz);
     c.x += shift;
     c.xyz = hsv2rgb(c.xyz);
 }
}
void hueShift (inout half3 c, half shift)
{
 if (shift != 0)
 {
     c = rgb2hsv(c);
     c.x += shift;
     c = hsv2rgb(c);
 }
}

inline half greyscale (half3 rgb)
{
    return dot(rgb, half3(0.22, 0.707, 0.071));
}

half remap (half Current, half2 OriginalRange, half2 TargetRange)
{
 half c = TargetRange.x + (Current - OriginalRange.x) * (TargetRange.y - TargetRange.x) / (OriginalRange.y - OriginalRange.x);
 return clamp(c,0.0,1.0);
}

half erode(half input, half offset)
{
    offset = 1-offset;
 if(offset != 0)
 {
        offset = clamp(offset,0.0,1.0);
     half c = (input - offset) / (1 - offset);
     return clamp(c,0.0,1.0);
 }
 return input;
}

//Custom Unity Functions and Macros

half2 setupUVs (half2 texcoord, half4 modifier)
{
 return texcoord * modifier.xy + modifier.zw;
}

half2 setupUVs (half2 texcoord, half4 modifier, half2 scroll)
{
 texcoord *= modifier.xy;
 texcoord += modifier.zw;
 return scrollUVs(texcoord, scroll);
}

//inline float4 test (in float3 pos)
//{
//    return mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, float4(pos, 1.0)));
//}
//inline float4 test(float4 pos) // overload for float4; avoids "implicit truncation" warning for existing shaders
//{
//    return test (pos.xyz);
//}

struct appdata_vu
{
    float4 vertex : POSITION;
    half2 texcoord0 : TEXCOORD0;
};

struct appdata_vn
{
 float4 vertex : POSITION;
 half3 normal : NORMAL;
};

struct appdata_vc
{
 float4 vertex : POSITION;
 half4 color : COLOR;
};

struct appdata_vuc
{
    float4 vertex : POSITION;
    half2 texcoord0 : TEXCOORD0;
    half4 color : COLOR;
};

struct appdata_vuuc
{
    float4 vertex : POSITION;
    half2 texcoord0 : TEXCOORD0;
    half2 texcoord1 : TEXCOORD1;
    half4 color : COLOR;
};

struct appdata_vnu
{
    float4 vertex : POSITION;
    half3 normal : NORMAL;
    half2 texcoord0 : TEXCOORD0;
};

struct appdata_vnuc
{
    float4 vertex : POSITION;
    half3 normal : NORMAL;
    half2 texcoord0 : TEXCOORD0;
    half4 color : COLOR;
};

struct v2f_vu
{
    float4 pos : SV_POSITION;
    half2 uv : TEXCOORD0;
};

struct v2f_vc
{
 float4 pos : SV_POSITION;
 half4 color : COLOR;
};

struct v2f_vuc
{
 float4 pos : SV_POSITION;
 half2 uv : TEXCOORD0;
 half4 color : COLOR;
};

struct v2f_vuuc
{
 float4 pos : SV_POSITION;
 half2 uv0 : TEXCOORD0;
 half2 uv1 : TEXCOORD1;
 half4 color : COLOR;
};

struct v2f_vf
{
 float4 pos : SV_POSITION;
 half color : COLOR;
};