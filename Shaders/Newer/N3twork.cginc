#ifndef ULTIMATE_INCLUDED
	#define ULTIMATE_INCLUDED

	//Vertex Data
	struct appdata_vu
	{
		float4 vertex: POSITION;
		half2 texcoord0: TEXCOORD0;
	};

	struct appdata_vn
	{
		float4 vertex: POSITION;
		half3 normal: NORMAL;
	};

	struct appdata_vc
	{
		float4 vertex: POSITION;
		half4 color: COLOR;
	};

	struct appdata_vuc
	{
		float4 vertex: POSITION;
		half2 texcoord0: TEXCOORD0;
		half4 color: COLOR;
	};

	struct appdata_vuuc
	{
		float4 vertex: POSITION;
		half2 texcoord0: TEXCOORD0;
		half2 texcoord1: TEXCOORD1;
		half4 color: COLOR;
	};

	struct appdata_vnu
	{
		float4 vertex: POSITION;
		half3 normal: NORMAL;
		half2 texcoord0: TEXCOORD0;
	};

	struct appdata_vnuc
	{
		float4 vertex: POSITION;
		half3 normal: NORMAL;
		half2 texcoord0: TEXCOORD0;
		half4 color: COLOR;
	};

	//Vertex to Fragment (Pixel)
	struct v2f_vu
	{
		float4 pos: SV_POSITION;
		half2 uv: TEXCOORD0;
	};

	struct v2f_vc
	{
		float4 pos: SV_POSITION;
		half4 color: COLOR;
	};

	struct v2f_vuc
	{
		float4 pos: SV_POSITION;
		half2 uv: TEXCOORD0;
		half4 color: COLOR;
	};

	struct v2f_vuuc
	{
		float4 pos: SV_POSITION;
		half2 uv0: TEXCOORD0;
		half2 uv1: TEXCOORD1;
		half4 color: COLOR;
	};

	struct v2f_vf
	{
		float4 pos: SV_POSITION;
		half color: COLOR;
	};

	// Scroll UVs
	half2 scrollUVs(half2 uv, half2 speed)
	{
		if (speed.x != 0 || speed.y != 0)
		{
			speed *= _Time.y;
			uv += speed;
		}
		return uv;
	}

	// Convert RBG to HSV
	half3 rgb2hsv(half3 c)
	{
		half4 K = half4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
		half4 p = lerp(half4(c.bg, K.wz), half4(c.gb, K.xy), step(c.b, c.g));
		half4 q = lerp(half4(p.xyw, c.r), half4(c.r, p.yzx), step(p.x, c.r));

		half d = q.x - min(q.w, q.y);
		half e = 1.0e-10;
		return half3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	}

	// Covert HSV to RGB
	half3 hsv2rgb(half3 c)
	{
		c = half3(c.x, clamp(c.yz, 0.0, 1.0));
		half4 K = half4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
		half3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
		return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
	}

	// Hue shift
	void hueShift(inout half4 c, half shift)
	{
		if (shift != 0)
		{
			c.xyz = rgb2hsv(c.xyz);
			c.x += shift;
			c.xyz = hsv2rgb(c.xyz);
		}
	}
	void hueShift(inout half3 c, half shift)
	{
		if(shift != 0)
		{
			c = rgb2hsv(c);
			c.x += shift;
			c = hsv2rgb(c);
		}
	}

	inline half greyscale(half3 rgb)
	{
		return dot(rgb, half3(0.22, 0.707, 0.071));
	}

	half remap(half In, half2 OldRange, half2 NewRange)
	{
		half output = NewRange.x + (In - OldRange.x) * (NewRange.y - NewRange.x) / (OldRange.y - OldRange.x);
		return output;
	}

	half2 remap(half2 In, half2 OldRange, half2 NewRange)
	{
		half2 output = half2(remap(In.x, OldRange, NewRange), remap(In.y, OldRange, NewRange));
		return output;
	}

	half4 remap(half4 In, half2 OldRange, half2 NewRange)
	{
		half4 output = half4(remap(In.x, OldRange, NewRange), remap(In.y, OldRange, NewRange), remap(In.z, OldRange, NewRange), remap(In.w, OldRange, NewRange));
		return output;
	}

	half erode(half input, half offset)
	{
		half e = 1 - offset;
		half c = input * (1 / e) - (offset / e);
		return clamp(c, 0.0, 1.0);
	}

	// Custom Unity Functions and Macros
	// Setup Uvs with custom Scale and Offset inputs
	half2 setupUVs(half2 texcoord, half4 modifier)
	{
		return texcoord * modifier.xy + modifier.zw;
	}

	half2 setupUVs(half2 texcoord, half4 modifier, half2 scroll)
	{
		texcoord *= modifier.xy;
		texcoord += modifier.zw;
		return scrollUVs(texcoord, scroll);
	}

	#define TRANSFORM_TEX_SCROLL(tex, name, scroll) ((tex.xy * name##_ST.xy + name##_ST.zw) + scroll * _Time.y)

	// Sprite Functions
	// Flip the sprite
	inline half4 flipSprite(in half3 pos, in half2 flip)
	{
		return half4(pos.xy * flip, pos.z, 1.0);
	}


	half2 flipbookUVs(half2 IN, half2 layout, half speed)
	{
		// get single sprite size
		float2 size = float2(1.0f / layout.x, 1.0f / layout.y);
		uint totalFrames = layout.x * layout.y;
		// use timer to increment index
		uint index = _Time.y * speed;
		// wrap x and y indexes
		uint indexX = index % layout.x;
		uint indexY = floor((index % totalFrames) / layout.x);
		// get offsets to our sprite index
		float2 offset = float2(size.x * indexX, -size.y * indexY);
		// get single sprite UV
		float2 newUV = IN * size;
		// flip Y (to start 0 from top)
		newUV.y = newUV.y + size.y * (layout.y - 1);
		return newUV + offset;
	}

	half2 flipbookUVs(half2 IN, half2 layout, half speed, half offset)
	{
		// get single sprite size
		float2 size = float2(1.0f / layout.x, 1.0f / layout.y);
		uint totalFrames = layout.x * layout.y;
		// use timer to increment index
		uint index = _Time.y * speed + offset;
		// wrap x and y indexes
		uint indexX = index % layout.x;
		uint indexY = floor((index % totalFrames) / layout.x);
		// get offsets to our sprite index
		float2 frameOffset = float2(size.x * indexX, -size.y * indexY);
		// get single sprite UV
		float2 newUV = IN * size;
		// flip Y (to start 0 from top)
		newUV.y = newUV.y + size.y * (layout.y - 1);
		return newUV + frameOffset;
	}


	half ring1(half4 uv, half center, half width, half roundness)
	{
		half aspectRatio = lerp(1, (_ScreenParams.x / _ScreenParams.y), roundness);
		half2 screenPos = uv.xy / uv.w;
		screenPos.x *= aspectRatio;
		half dist = distance(screenPos, half2(0.5 * aspectRatio, 0.5)) - center;
		half ring = (1 - (abs(dist) / width)) * ((dist - width) < 0 && (dist + width) > 0);
		return ring;
	}

	half ring2(half2 uv, half center, half width)
	{
		half dist = distance(uv, half2(0.5, 0.5)) - center;
		half ring = (1 - (abs(dist) / width)) * ((dist - width) < 0 && (dist + width) > 0);
		return ring;
	}

#endif