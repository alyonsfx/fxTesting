using System;
using UnityEditor;
using UnityEngine;

namespace PersonalEditorTools.Editor
{
	public class AnimationClipEditor : EditorWindow
	{
		private AnimationClip input;
		private AnimationClip prevInput;
		private bool showProperties;
		private string[] clipPaths;
		private string[] clipProperties;
		private Type[] clipTypes;
		private AnimationCurve[] clipCurves;

		private string findText;
		private string replaceText;
		private Vector2 scrollPos;
		private bool isLegacy;

		[MenuItem("Tools/Animation Clip Editor")]
		public static void Open()
		{
			GetWindow<AnimationClipEditor>(false, "Animation Clip Editor", true);
		}

		private void OnGUI()
		{
			// EditorGUIUtility.labelWidth = EditorGUIUtility.currentViewWidth * 0.3f;
			var nullStyle = new GUIStyle(GUI.skin.button) {normal = {textColor = new Color(0.2f, 0.2f, 0.2f, 1f)}, fixedWidth = 125};
			var baseStyle = new GUIStyle(GUI.skin.button) {fixedWidth = 125};

			EditorGUILayout.BeginHorizontal();
			prevInput = input;
			input = EditorGUILayout.ObjectField("Clip:", input, typeof(AnimationClip), false) as AnimationClip;
			EditorGUILayout.EndHorizontal();

			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			if (GUILayout.Button("Show", input == null ? nullStyle : baseStyle))
			{
				if (input == null)
				{
					// L.Group("Animation Editor Tool", "No clip selected");
				}
				else
				{
					GetClipProperties();
				}
			}

			GUILayout.FlexibleSpace();
			if (GUILayout.Button("Clear Selection", baseStyle))
			{
				ClearAll();
			}
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();
			EditorGUILayout.Space();

			EditorGUIUtility.labelWidth = EditorGUIUtility.currentViewWidth * 0.25f;
			EditorGUILayout.BeginHorizontal();
			findText = EditorGUILayout.TextField("Find", findText);
			EditorGUILayout.EndHorizontal();

			EditorGUILayout.BeginHorizontal();
			replaceText = EditorGUILayout.TextField("Replace with", replaceText);
			EditorGUILayout.EndHorizontal();

			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			if (GUILayout.Button("Rename", input == null ? nullStyle : baseStyle))
			{
				if (input == null)
				{
					// L.Group("Animation Editor Tool", "No clip selected");
				}
				else if (string.IsNullOrEmpty(findText) && string.IsNullOrEmpty(replaceText))
				{
					// L.Group("Animation Editor Tool", "No text entered");
				}
				else
				{
					RenameProperties();
					SetClipProperties();
				}
			}

			GUILayout.FlexibleSpace();
			if (GUILayout.Button("Clear Text", baseStyle))
			{
				findText = null;
				replaceText = null;
			}
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();

			if (prevInput != input)
			{
				clipPaths = clipProperties = null;
				clipTypes = null;
				clipCurves = null;
				showProperties = false;
			}
			else if (showProperties)
			{
				ShowProperties();
			}
		}

		private void ClearAll()
		{
			input = null;
			clipPaths = clipProperties = null;
			clipTypes = null;
			clipCurves = null;
			showProperties = false;
		}

		private void ShowProperties()
		{
			EditorGUIUtility.labelWidth = EditorGUIUtility.currentViewWidth - 150;
			EditorGUILayout.Space();
			EditorGUILayout.LabelField($"{clipPaths.Length + 1} curves found");
			EditorGUILayout.Space();
			scrollPos = EditorGUILayout.BeginScrollView(scrollPos);
			for (var i = 0; i < clipPaths.Length; i++)
			{
				EditorGUILayout.BeginHorizontal();
				EditorGUILayout.LabelField($"{clipPaths[i]} : {clipProperties[i]}");
				GUILayout.FlexibleSpace();
				if (GUILayout.Button("Copy Path"))
				{
					EditorGUIUtility.systemCopyBuffer = clipPaths[i];
				}
				EditorGUILayout.EndHorizontal();
			}
			EditorGUILayout.EndScrollView();
		}

		private void GetClipProperties()
		{
			var bindings = AnimationUtility.GetCurveBindings(input);
			clipPaths = new string[bindings.Length];
			clipProperties = new string[bindings.Length];
			clipTypes = new Type[bindings.Length];
			clipCurves = new AnimationCurve[bindings.Length];
			for (var i = 0; i < bindings.Length; i++)
			{
				clipPaths[i] = bindings[i].path;
				clipProperties[i] = bindings[i].propertyName;
				clipTypes[i] = bindings[i].type;
				clipCurves[i] = AnimationUtility.GetEditorCurve(input, bindings[i]);
			}

			showProperties = true;
		}

		private void RenameProperties()
		{
			isLegacy = input.legacy;
			for (var i = 0; i < clipPaths.Length; i++)
			{
				clipPaths[i] = clipPaths[i].Replace(findText, replaceText);
			}
		}

		private void SetClipProperties()
		{
			input.legacy = false;
			input.ClearCurves();
			for (var i = 0; i < clipPaths.Length; i++)
			{
				input.SetCurve(clipPaths[i], clipTypes[i], clipProperties[i], clipCurves[i]);
			}
			input.legacy = isLegacy;
		}
	}
}