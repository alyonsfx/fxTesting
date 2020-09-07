using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;

namespace PersonalEditorTools.Editor
{
	public class FindReferencesWindow : EditorWindow
	{
		private Object input;
		private Object prevInput;
		private readonly List<string> results = new List<string>();
		private Vector2 scroll;
		private bool showResults;
		private bool searchMaterials;
		private string fileName;
		private string targetPath;

		[MenuItem("Tools/Find References")]
		public static void Open()
		{
			GetWindow<FindReferencesWindow>(false, "Find References", true);
		}

		private void OnGUI()
		{
			EditorGUIUtility.labelWidth = EditorGUIUtility.currentViewWidth * 0.5f;
			EditorGUILayout.BeginHorizontal();

			// Show object field and search type
			prevInput = input;
			input = EditorGUILayout.ObjectField(input, typeof(Object), false);

			// Reset results if we change the target
			if (prevInput != input)
			{
				results.Clear();
				showResults = false;
			}

			if (GUILayout.Button("Prefabs") && input != null)
			{
				searchMaterials = false;
				SearchProject(input);
			}

			if (GUILayout.Button("Materials") && input != null)
			{
				searchMaterials = true;
				SearchProject(input);
			}

			EditorGUILayout.EndHorizontal();

			EditorGUILayout.BeginHorizontal();


			if (showResults)
			{
				EditorGUILayout.LabelField("References Found: " + results.Count.ToString());
			}
			else
			{
				EditorGUILayout.LabelField("References Found:");
			}

			if (GUILayout.Button("Clear"))
			{
				ClearAll();
			}

			EditorGUILayout.EndHorizontal();

			// Show results
			if (showResults)
			{
				ShowObjects();
			}
		}

		private void ClearAll()
		{
			input = null;
			results.Clear();
			showResults = false;
		}

		private void SearchProject(Object selectedObject, bool isBulk = false)
		{
			results.Clear();

			// Find the path to the target file
			fileName = selectedObject.name;
			var t = fileName.Split('.');
			fileName = t[0];
			targetPath = AssetDatabase.GetAssetPath(selectedObject);

			// Look at all prefabs or materials
			var searchType = searchMaterials ? "t:Material" : "t:Prefab";

			// Store file paths
			var allObjects = AssetDatabase.FindAssets(searchType);
			foreach (var thisObject in allObjects)
			{
				var temp = AssetDatabase.GUIDToAssetPath(thisObject);

				// Compare dependency
				var dependencies = AssetDatabase.GetDependencies(temp);
				if (ArrayUtility.Contains(dependencies, targetPath))
					results.Add(temp);
			}

			showResults = true;
		}

		private void ShowObjects()
		{
			scroll = EditorGUILayout.BeginScrollView(scroll);
			{
				if (results.Count < 1)
				{
					NoResults();
				}
				else if (results.Count < 2)
				{
					if (results[0] != targetPath)
					{
						YesResults();
					}
					else
					{
						NoResults();
					}
				}
				else
				{
					YesResults();
				}
			}
			EditorGUILayout.EndScrollView();
		}

		private void NoResults()
		{
			var warning = results.Count < 1 ? "No occurrence found" : "Selected object is only occurrence";
			EditorGUILayout.HelpBox(warning, MessageType.Info);
			if (GUILayout.Button("Delete"))
			{
				if (!searchMaterials)
				{
					AssetDatabase.DeleteAsset(targetPath);
					ClearAll();
				}
				else
				{
					if (EditorUtility.DisplayDialog("Are you sure you want to delete this?", fileName + " might still be used in a prefab", "Confirm", "Cancel"))
					{
						AssetDatabase.DeleteAsset(targetPath);
						ClearAll();
					}
				}
			}
		}

		private void YesResults()
		{
			foreach (var file in results)
			{
				EditorGUILayout.BeginHorizontal();
				{
					EditorGUILayout.LabelField(Path.GetFileNameWithoutExtension(file));
					EditorGUILayout.Space();
					if (GUILayout.Button("Show"))
					{
						EditorGUIUtility.PingObject(AssetDatabase.LoadAssetAtPath(file, typeof(Object)));
					}

					if (!searchMaterials)
					{
						if (GUILayout.Button("Open"))
						{
							AssetDatabase.OpenAsset(AssetDatabase.LoadAssetAtPath(file, typeof(Object)));
							EditorApplication.ExecuteMenuItem("Window/General/Hierarchy");
						}
					}
				}
				EditorGUILayout.EndHorizontal();
			}
		}

	}
}