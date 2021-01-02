//© Dicewrench Designs LLC 2020
//All Rights Reserved, used with permission
//Last Owned by: Allen White (allen@dicewrenchdesigns.com)

float ThreeSixtyAngle(float angle)
{
   return angle * 0.01745399;
}

float2 ComputePivotRotation(float2 baseUV, float angle, float2 pivot)
{
   float a = ThreeSixtyAngle(angle);
   float rot_cos;
   float rot_sin;
   sincos(a, rot_sin, rot_cos);
   float2x2 rotationMatrix = float2x2(rot_cos, -rot_sin, rot_sin, rot_cos);
   baseUV -= pivot;
   float2 newUV = mul(baseUV, rotationMatrix);
   return newUV  + pivot;
}

float2 ComputeRotatedUV(float2 baseUV, float angle)
{
   return ComputePivotRotation(baseUV, angle, float2(0.5,0.5));
} 

float CalculateGradient(float2 uv, float angle, float offset, float contrast)
{
   float2 gradUV = ComputeRotatedUV(uv, angle);
   gradUV -= offset.xx;
   gradUV *= contrast.xx;
   return saturate(gradUV);
}

float CalculateShine(float2 uv, float width, float frequency, float rate)
{
   float gradient = saturate(sin((uv.x * frequency) + (_Time.y * rate)) - width);
   return gradient;
}

fixed ZeroOneZero(fixed grad)
{
   return 1.0 - saturate(abs((grad * 2.0) - 1.0));
}

float2 GetScreenUV(float2 clipPos, float4 scaleOffset)
{
	float4 SSobjectPosition = UnityObjectToClipPos (float4(0,0,0,1.0)) ;
	float2 screenUV = float2(clipPos.x,clipPos.y);
	float screenRatio = _ScreenParams.y/_ScreenParams.x;

	screenUV.x -= SSobjectPosition.x/(SSobjectPosition.w);
	screenUV.y -= SSobjectPosition.y/(SSobjectPosition.w); 

	screenUV.y *= screenRatio;

	screenUV *= scaleOffset.xy;
   screenUV += scaleOffset.zw;
	screenUV *= SSobjectPosition.w;

	return screenUV;
}

fixed3 ApplyOverlay(fixed3 base, fixed3 overlay)
{
   return saturate( base + ( (base * ((2.0.xxx * overlay - 1.0.xxx))) * (1.0.xxx - base) ) );
}