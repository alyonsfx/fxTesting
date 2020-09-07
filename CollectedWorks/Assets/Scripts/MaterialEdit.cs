using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class MaterialEdit {

	public static void SetMaterialColor(Material targetMaterial, string targetProperty, Color targetColor) {
		if (targetMaterial != null && targetMaterial.HasProperty(targetProperty)) {
			targetMaterial.SetColor(targetProperty, targetColor);
		} else {
			Debug.LogWarning(targetProperty + " does not exhist on " + targetMaterial.name);
		}
	}

	public static void SetMaterialColor(Material targetMaterial, Color targetColor) {
		SetMaterialColor(targetMaterial, "_Color", targetColor);
	}

	public static void SetMaterialFloat(Material targetMaterial, string targetProperty, float value) {
		if (targetMaterial != null && targetMaterial.HasProperty(targetProperty)) {
			targetMaterial.SetFloat(targetProperty, value);
		} else {
			Debug.LogWarning(targetProperty + " does not exhist on " + targetMaterial.name);
		}
	}

	public static void SetMaterialVector(Material targetMaterial, string targetProperty, Vector4 value) {
		if (targetMaterial != null && targetMaterial.HasProperty(targetProperty)) {
			targetMaterial.SetVector(targetProperty, value);
		} else {
			Debug.LogWarning(targetProperty + " does not exhist on " + targetMaterial.name);
		}
	}
	public static void SetMaterialVector(Material targetMaterial, string targetProperty, Vector3 value) {
		if (targetMaterial != null && targetMaterial.HasProperty(targetProperty)) {
			Vector4 temp = targetMaterial.GetVector(targetProperty);
			temp = new Vector4(value.x, value.y, value.z, temp.w);
			targetMaterial.SetVector(targetProperty, temp);
		} else {
			Debug.LogWarning(targetProperty + " does not exhist on " + targetMaterial.name);
		}
	}

	public static void SetParticleSystemColor(ParticleSystem targetPS, Color targetColor) {
		var m = targetPS.main;
		m.startColor = targetColor;
	}

	public static void SetMaterialTexture(Material targetMaterial, string targetProperty, Texture targetTexture) {
		if (targetMaterial.HasProperty(targetProperty)) {
			targetMaterial.SetTexture(targetProperty, targetTexture);
		} else {
			Debug.LogWarning(targetProperty + " does not exhist on " + targetMaterial.name);
		}
	}
	public static Texture SetStoreMaterialTexture(Material targetMaterial, string targetProperty, Texture targetTexture) {
		if (targetMaterial.HasProperty(targetProperty)) {
			Texture originalTexture = targetMaterial.GetTexture(targetProperty);
			targetMaterial.SetTexture(targetProperty, targetTexture);
			return originalTexture;
		} else {
			Debug.LogWarning(targetProperty + " does not exhist on " + targetMaterial.name);
			return null;
		}
	}
}
