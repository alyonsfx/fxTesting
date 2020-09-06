using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;

public class FindReferencesWindow : EditorWindow
{
	private searchType inputType;
	private AnimationClip inputA;
	private Material inputM;
	private Shader inputS;
	private Texture inputT;
	private List<string> results = new List<string>();
	private Vector2 scroll;
	private bool showResults = false;
	private bool searchMaterials = false;
	private searchType previousInputType;

	[MenuItem("Tools/Find References")]
	public static void Open()
	{
		GetWindow<FindReferencesWindow>(false, "Find References", true);
	}

	public enum searchType
	{
		animation,
		material,
		texture,
		shader
	};

	void OnGUI()
	{
		EditorGUILayout.BeginHorizontal();
		if (previousInputType != inputType)
		{
			inputA = null;
			inputM = null;
			inputS = null;
			inputT = null;
			showResults = false;
		}
		previousInputType = inputType;
		EditorGUIUtility.labelWidth = 35f;
		inputType = (searchType)EditorGUILayout.EnumPopup("Find:", inputType);
		EditorGUILayout.Space();
		if (showResults)
		{
			EditorGUILayout.LabelField(results.Count.ToString());
		}
		else
		{
			EditorGUILayout.LabelField("");
		}
		EditorGUILayout.EndHorizontal();

		EditorGUIUtility.labelWidth = EditorGUIUtility.currentViewWidth * 0.5f;
		displayInput();
	}

	private void displayInput()
	{

		switch (inputType)
		{
			case searchType.animation:
				{
					EditorGUILayout.BeginHorizontal();
					AnimationClip prev = inputA;
					inputA = EditorGUILayout.ObjectField(inputA, typeof(AnimationClip), false) as AnimationClip;
					if (GUILayout.Button("Find") && inputA != null)
					{
						searchMaterials = false;
						seachObjects(findTarget(inputA));
						showResults = true;
					}
					if (GUILayout.Button("Clear"))
					{
						inputA = null;
						results.Clear();
						showResults = false;
					}
					EditorGUILayout.EndHorizontal();
					showObjects();
					break;
				}
			case searchType.material:
				{
					EditorGUILayout.BeginHorizontal();
					Material prev = inputM;
					inputM = EditorGUILayout.ObjectField(inputM, typeof(Material), false) as Material;
					if (GUILayout.Button("Find") && inputM != null)
					{
						searchMaterials = false;
						seachObjects(findTarget(inputM));
						showResults = true;
					}
					if (GUILayout.Button("Clear"))
					{
						inputM = null;
						results.Clear();
						showResults = false;
					}
					EditorGUILayout.EndHorizontal();
					showObjects();
					break;
				}
			case searchType.shader:
				{
					EditorGUILayout.BeginHorizontal();
					Shader prev = inputS;
					inputS = EditorGUILayout.ObjectField(inputS, typeof(Shader), false) as Shader;
					if (GUILayout.Button("Materials") && inputS != null)
					{
						searchMaterials = true;
						seachObjects(findTarget(inputS));
						showResults = true;
					}
					if (GUILayout.Button("Prefabs") && inputS != null)
					{
						searchMaterials = false;
						seachObjects(findTarget(inputS));
						showResults = true;
					}
					if (GUILayout.Button("Clear"))
					{
						inputT = null;
						results.Clear();
						showResults = false;
					}
					EditorGUILayout.EndHorizontal();
					showObjects();
					break;
				}
			case searchType.texture:
				{
					EditorGUILayout.BeginHorizontal();
					Texture prev = inputT;
					inputT = EditorGUILayout.ObjectField(inputT, typeof(Texture), false) as Texture;
					if (GUILayout.Button("Materials") && inputT != null)
					{
						searchMaterials = true;
						seachObjects(findTarget(inputT));
						showResults = true;
					}
					if (GUILayout.Button("Prefabs") && inputT != null)
					{
						searchMaterials = false;
						seachObjects(findTarget(inputT));
						showResults = true;
					}
					if (GUILayout.Button("Clear"))
					{
						inputT = null;
						results.Clear();
						showResults = false;
					}
					EditorGUILayout.EndHorizontal();
					showObjects();
					break;
				}
		}
	}

	private string findTarget(AnimationClip a)
	{
		return AssetDatabase.GetAssetPath(a);
	}

	private string findTarget(Material m)
	{
		return AssetDatabase.GetAssetPath(m);
	}

	private string findTarget(Shader s)
	{
		return AssetDatabase.GetAssetPath(s);
	}

	private string findTarget(Texture t)
	{
		return AssetDatabase.GetAssetPath(t);
	}

	private void seachObjects(string target)
	{
		string searchTerm = searchMaterials ? "t:Material" : "t:Prefab";
		string[] allObjects = AssetDatabase.FindAssets(searchTerm);
		results.Clear();
		for (int i = 0; i < allObjects.Length; i++)
		{
			string temp = AssetDatabase.GUIDToAssetPath(allObjects[i]);
			string[] dep = AssetDatabase.GetDependencies(temp);
			if (ArrayUtility.Contains(dep, target))
				results.Add(temp);
		}
	}

	private void showObjects()
	{
		if (!showResults)
		{
			return;
		}

		scroll = EditorGUILayout.BeginScrollView(scroll);
		{
			if (results.Count == 0)
			{
				EditorGUILayout.HelpBox("No Occurences Found", MessageType.Info);
			}
			else
			{
				for (int i = 0; i < results.Count; i++)
				{
					EditorGUILayout.BeginHorizontal();
					{
						EditorGUILayout.LabelField(Path.GetFileNameWithoutExtension(results[i]));
						EditorGUILayout.Space();
						if (GUILayout.Button("Show"))
						{
							EditorGUIUtility.PingObject(AssetDatabase.LoadAssetAtPath(results[i], typeof(Object)));
						}
					}
					EditorGUILayout.EndHorizontal();
				}
			}
		}
		EditorGUILayout.EndScrollView();
	}
}