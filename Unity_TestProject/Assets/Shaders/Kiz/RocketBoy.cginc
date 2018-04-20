//#include "Lighting.cginc"

float3 rgb_to_hsv(float3 RGB)
{
    float r = RGB.x;
    float g = RGB.y;
    float b = RGB.z;

    float minChannel = min(r, min(g, b));
    float maxChannel = max(r, max(g, b));

    float h = 0;
    float s = 0;
    float v = maxChannel;

    float delta = maxChannel - minChannel;

    if (delta != 0)
    {
        s = delta / v;

        if (r == v) h = (g - b) / delta;
        else if (g == v) h = 2 + (b - r) / delta;
        else if (b == v) h = 4 + (r - g) / delta;
    }

    return float3(h, s, v);
}

float3 hsv_to_rgb(float3 HSV)
{
    float3 RGB = HSV.z;

    float h = HSV.x;
    float s = HSV.y;
    float v = HSV.z;

    float i = floor(h);
    float f = h - i;

    float p = (1.0 - s);
    float q = (1.0 - s * f);
    float t = (1.0 - s * (1 - f));

    if (i == 0) { RGB = float3(1, t, p); }
    else if (i == 1) { RGB = float3(q, 1, p); }
    else if (i == 2) { RGB = float3(p, 1, t); }
    else if (i == 3) { RGB = float3(p, q, 1); }
    else if (i == 4) { RGB = float3(t, p, 1); }
    else /* i == -1 */ { RGB = float3(1, p, q); }

    RGB *= v;

    return RGB;
}

fixed4 fresnel (fixed4 vertex, fixed3 normal, fixed width, fixed intensity, fixed4 fresnelColor)
{
	fixed3 viewDir = normalize(ObjSpaceViewDir(vertex));
	fixed dotProduct = 1 - saturate(pow(dot(viewDir, normal), width));
	fresnelColor *= intensity * dotProduct;
	return saturate(fresnelColor);
}

// fresnel results masked by (1 - BLUE Vertex Channel
fixed4 fresnelCharacter (fixed4 vertex, fixed3 normal, fixed4 color, fixed width, fixed4 fresnelColor)
{
	fixed3 viewDir = normalize(ObjSpaceViewDir(vertex));
	fixed dotProduct = 1 - saturate(pow(dot(viewDir, normal), width));
	fresnelColor *= dotProduct * (1.0 - color.b);
	fresnelColor.a = color.b;
	return saturate(color);


	//fixed3 viewDir = normalize(ObjSpaceViewDir(vertex));
	//fixed dotProduct = 1.0 - (saturate(dot(viewDir, normal)) * 1.0 - color.b);

	//fresnelColor.a = color.b + smoothstep(1 - width, 1.0, dotProduct) * (1.0 - color.b);
	//fresnelColor.xyz *= smoothstep(fixed3(0, 0, 0), fixed3(1, 1, 1), dotProduct) * (1.0 - color.b) * dotProduct * 0.75f;
	//return saturate(fresnelColor);
}

// adjust vertex position based off of distance from center
fixed3 jitter (fixed distance, fixed speed, fixed time, fixed4 color, fixed3 normal, fixed3 position)
{
	if (distance != 0.0 && speed != 0)
	{
		fixed3 ripple =  sin(color.r * normal * speed * time * 100.0);
		ripple = position + (ripple * distance * 0.05);
		return ripple;
	}
	return position;
}

// adjust vertex position based off of distance from center, masked by RED Vertex Channel
fixed3 jitterCharacter (fixed distance, fixed speed, fixed4 color, fixed4 texcoord, fixed time, fixed3 normal, fixed3 position)
{
	if (distance != 0.0 && speed != 0)
	{
		fixed ripple =  sin(normal.z * speed * time * 100.0);
		ripple *= color.r;
		ripple = position + (fixed3(ripple, ripple, ripple) * normal * distance * 0.05);
		return ripple;
	}
	return position;
}

// light probe based diffuse lighting
fixed3 diffuse (fixed3 normal)
{
	fixed3 worldNormal = UnityObjectToWorldNormal(normal);
	fixed3 shl = ShadeSH9(fixed4(worldNormal, 1));
	shl = saturate(shl);
	return shl;
}

// light probe based diffuse lighting and specular highlights
void diffuseSpec (fixed3 normal, fixed4 vertex, fixed rolloff, fixed intensity, inout fixed3 diffuse, inout fixed3 spec)
{
	fixed3 worldNormal = UnityObjectToWorldNormal(normal);
	fixed3 shl = ShadeSH9(fixed4(worldNormal, 1));
	diffuse = saturate(shl);

	fixed3 worldV = normalize(-WorldSpaceViewDir(vertex));
	fixed3 refl = reflect(worldV, worldNormal);
	fixed3 worldLightDir = _WorldSpaceLightPos0;
	//spec = dot(worldLightDir, refl);
	spec = saturate(shl * pow(saturate(dot(worldLightDir, refl)), rolloff) * intensity);
}

//combines two normal maps
fixed3 combineNormalMaps (fixed3 base, fixed3 detail)
{
	base.z += 1.0;
	detail.xy *= -1.0;
	base *= dot(base, detail) / base.z - detail;
	return base;
}

// texture rotation
fixed2 texRotate (fixed2 uv, fixed speed, fixed time)
{
	uv -= 0.5;
	fixed s = sin(-speed * time);
	fixed c = cos(-speed * time);
	fixed2x2 rotationMatrix = fixed2x2(c, -s, s, c);
	rotationMatrix *= 0.5;
	rotationMatrix += 0.5;
	rotationMatrix = rotationMatrix * 2 - 1;
	uv = mul(uv, rotationMatrix);
	uv += 0.5;
	return uv;
}

//Texture Saturation
fixed4 desaturate (fixed4 inTex, fixed saturation)
{
	fixed4 tex = fixed4(inTex.x * 0.3, inTex.y * 0.59, inTex.z * 0.11, inTex.a);
	fixed bright = tex.x + tex.y + tex.z;
	tex.xyz = lerp(inTex.xyz, bright.xxx, saturation);
	return tex;
}