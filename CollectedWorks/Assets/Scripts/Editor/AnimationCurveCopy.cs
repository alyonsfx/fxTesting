using UnityEngine;
using UnityEditor;
using System;
using System.Collections.Generic;
using System.Linq;

/*
 * Get clips on selected object
 * Get curve bindings
 * Select binding
 * Copy curve
 * Create new curve
 *
 */

public class AnimationTools
{
	[MenuItem("Assets/Modify Animation")]
	private static void SelectClip()
	{
		var temp = (AnimationClip) Selection.activeObject;
		AnimationCurveCopy.ShowWindow();
	}

	[MenuItem("Assets/Modify Animation", true)]
	private static bool SelectClipCheck()
	{
		return Selection.activeObject is AnimationClip;
	}
}


public class AnimationCurveCopy : EditorWindow
{
	[MenuItem("Window/Animation Copier")]
	public static void ShowWindow()
	{
		GetWindow(typeof(AnimationCurveCopy));
	}

	private AnimationClip selectedAnimationClip;
	private bool initialized;
	private CurveInformation curveInformation;
	private Vector2 scrollViewVector;
	private static List<AnimationClipCurveData> animationCurveClipboard = new List<AnimationClipCurveData>();
	private int propertyIndex;

	public void OnGUI()
	{
		if (!initialized)
		{
			selectedAnimationClip = (AnimationClip) Selection.activeObject;
			initialized = true;
		}
		selectedAnimationClip = (AnimationClip)EditorGUILayout.ObjectField(selectedAnimationClip, typeof(AnimationClip), false);

		// var bindings = AnimationUtility.GetCurveBindings(selectedAnimationClip);

		if (GUILayout.Button("Copy", EditorStyles.miniButton))
		{
			animationCurveClipboard = curveInformation.GetSelectedAnimationCurves();
		}

		if (GUILayout.Button("Copy All", EditorStyles.miniButton))
		{
			animationCurveClipboard = AnimationUtility.GetCurveBindings(selectedAnimationClip).Select(x => new AnimationClipCurveData(x)).ToList();
		}

		if (GUILayout.Button("Paste", EditorStyles.miniButton))
		{
			Paste();
		}

		if (GUILayout.Button("Remove", EditorStyles.miniButton))
		{
			var curvesToDelete = curveInformation.GetSelectedAnimationCurves();
			var allCurves = curveInformation.GetSelectedAnimationCurves(new List<AnimationClipCurveData>(), true);
			selectedAnimationClip.ClearCurves();
			foreach (var curveInfo in allCurves)
			{
				if (curveInfo == null)
				{
					continue;
				}

				if (!curvesToDelete.Contains(curveInfo))
				{
					InsertCurve(curveInfo);
				}
			}

			Refresh();
		}

		if (GUILayout.Button("Refresh", EditorStyles.miniButton))
		{
			Refresh();
		}

		EditorGUILayout.EndHorizontal();
		foreach (var binding in AnimationUtility.GetCurveBindings(selectedAnimationClip))
		{
			UpdateCurveInformation(selectedAnimationClip.name, curveInformation, new AnimationClipCurveData(binding));
		}

		scrollViewVector = EditorGUILayout.BeginScrollView(scrollViewVector);
		curveInformation.DisplayCurveInformation();
		EditorGUILayout.EndScrollView();
	}

	private void Refresh()
	{
		curveInformation = new CurveInformation(selectedAnimationClip.name);
	}

	private void Paste()
	{
		foreach (var animationClipCurveData in animationCurveClipboard)
		{
			if (animationClipCurveData == null)
			{
				continue;
			}

			InsertCurve(animationClipCurveData);
		}
	}

	private void InsertCurve(AnimationClipCurveData animationClipCurveData)
	{
		var editorCurveBinding = new EditorCurveBinding();
		editorCurveBinding.path = animationClipCurveData.path;
		editorCurveBinding.propertyName = animationClipCurveData.propertyName;
		editorCurveBinding.type = animationClipCurveData.type;

		AnimationUtility.SetEditorCurve(selectedAnimationClip, editorCurveBinding, animationClipCurveData.curve);
	}

	private void UpdateCurveInformation(string nameOfClip, CurveInformation curveInformationToUpdate, AnimationClipCurveData animationCurveData)
	{
		var curveInformationNames = animationCurveData.path.Split(new string[] {"/"}, StringSplitOptions.RemoveEmptyEntries).ToList();

		curveInformationNames.Insert(0, nameOfClip);
		curveInformationNames.Add(animationCurveData.type.ToString());
		curveInformationNames.Add(animationCurveData.propertyName);

		curveInformationToUpdate.AddIfNonexistent(curveInformationNames, animationCurveData);
	}

	private class CurveInformation
	{
		public bool IsChecked { get; set; }
		public AnimationClipCurveData AnimationClipCurveData { get; set; }
		public string Name { get; private set; }
		public List<CurveInformation> Children { get; private set; }

		public CurveInformation(string name)
		{
			Name = name;
			Children = new List<CurveInformation>();
		}

		public void DisplayCurveInformation()
		{
			IsChecked = EditorGUILayout.ToggleLeft(Name, IsChecked);

			EditorGUI.indentLevel++;
			foreach (var child in Children)
			{
				child.DisplayCurveInformation();
			}

			EditorGUI.indentLevel--;
		}

		public List<AnimationClipCurveData> GetSelectedAnimationCurves(List<AnimationClipCurveData> animationCurves = null, bool overwriteChecked = false)
		{
			if (animationCurves == null)
			{
				animationCurves = new List<AnimationClipCurveData>();
			}

			if (IsChecked || overwriteChecked)
			{
				animationCurves.Add(this.AnimationClipCurveData);
				foreach (var child in Children)
				{
					animationCurves = child.GetSelectedAnimationCurves(animationCurves, true);
				}
			}
			else
			{
				foreach (var child in Children)
				{
					animationCurves = child.GetSelectedAnimationCurves(animationCurves, false);
				}
			}

			return animationCurves;
		}

		public CurveInformation AddIfNonexistent(List<string> path, AnimationClipCurveData animationCLipCurveData)
		{
			if (Name.Equals(path[0]))
			{
				if (path.Count == 1)
				{
					AnimationClipCurveData = animationCLipCurveData;
					return this;
				}

				var pathReduced = path;
				pathReduced.RemoveAt(0);
				foreach (var curveInformation in Children)
				{
					if (curveInformation.Name.Equals(pathReduced[0]))
					{
						var childResult = curveInformation.AddIfNonexistent(pathReduced, animationCLipCurveData);
						if (childResult != null)
						{
							return childResult;
						}
					}
				}
			}

			var newChild = new CurveInformation(path[0]);
			Children.Add(newChild);
			if (path.Count == 1)
			{
				newChild.AnimationClipCurveData = animationCLipCurveData;
				return newChild;
			}
			else
			{
				var pathReduced = path;
				pathReduced.RemoveAt(0);
				return newChild.AddIfNonexistent(pathReduced, animationCLipCurveData);
			}
		}
	}
}