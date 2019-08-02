using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;

public class AnimOccurenceWindow : EditorWindow
{
	[MenuItem("Tools/Find Animation Occurence")]
	public static void Open()
	{
		GetWindow<AnimOccurenceWindow>(false, "Animation Occurences", true);
	}

	private AnimationClip input;
	private List<string> prefabs = new List<string>();
	private Vector2 results;
	private bool showResults = false;

	void OnGUI()
	{
		GUILayout.BeginHorizontal();
		AnimationClip prev = input;
		input = EditorGUILayout.ObjectField(input, typeof(AnimationClip), false) as AnimationClip;
		if (GUILayout.Button("Find") && input != null)
		{
			searchObjects(input);
			showResults = true;
		}
		if (GUILayout.Button("Clear"))
		{
			input = null;
			prefabs.Clear();
			showResults = false;
		}
		GUILayout.EndHorizontal();

		showObjects();
	}

	private void searchObjects(AnimationClip a)
	{
		string path = AssetDatabase.GetAssetPath(a);
		string[] allObjects = AssetDatabase.FindAssets("t:Prefab");
		prefabs.Clear();
		for (int i = 0; i < allObjects.Length; i++)
		{
			string temp = AssetDatabase.GUIDToAssetPath(allObjects[i]);
			string[] dep = AssetDatabase.GetDependencies(temp);
			if (ArrayUtility.Contains(dep, path))
				prefabs.Add(temp);
		}
	}

	private void showObjects()
	{
		if (!showResults)
		{
			return;
		}

		results = GUILayout.BeginScrollView(results);
		{
			if (prefabs.Count == 0)
			{
				EditorGUILayout.HelpBox("No Occurences Found", MessageType.Info);
			}
			else
			{
				for (int i = 0; i < prefabs.Count; i++)
				{
					GUILayout.BeginHorizontal();
					{
						GUILayout.Label(Path.GetFileNameWithoutExtension(prefabs[i]));
						GUILayout.FlexibleSpace();
						if (GUILayout.Button("Show"))
						{
							EditorGUIUtility.PingObject(AssetDatabase.LoadAssetAtPath(prefabs[i], typeof(Object)));
						}
					}
					GUILayout.EndHorizontal();
				}
			}
		}
		GUILayout.EndScrollView();
	}
}