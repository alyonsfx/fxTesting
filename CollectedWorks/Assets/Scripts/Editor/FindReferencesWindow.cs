using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;

namespace Editor
{
	public class FindReferencesWindow : EditorWindow
	{
		private enum SearchType
		{
			Animation,
			Controller,
			Material,
			Prefab,
			Texture,
			Shader
		};
		private SearchType inputType;
		private SearchType previousInputType;
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
			EditorGUILayout.BeginHorizontal();
			// Reset everything when we change search type
			if (previousInputType != inputType)
			{
				ClearAll();
			}
			previousInputType = inputType;
			EditorGUIUtility.labelWidth = 66f;
			inputType = (SearchType)EditorGUILayout.EnumPopup("Input Type:", inputType);
			EditorGUILayout.Space();
			// Show count
			if (showResults)
			{
				EditorGUILayout.LabelField("References Found: " + results.Count.ToString());
			}
			else
			{
				EditorGUILayout.LabelField("References Found:");
			}
			EditorGUILayout.EndHorizontal();

			EditorGUIUtility.labelWidth = EditorGUIUtility.currentViewWidth * 0.5f;
			// Show object field and search type
			InputDisplay();
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

		private void InputDisplay()
		{
			EditorGUILayout.BeginHorizontal();
			switch (inputType)
			{
				case SearchType.Animation:
				{
					prevInput = input;
					input = EditorGUILayout.ObjectField(input, typeof(AnimationClip), false) as AnimationClip;
					// Reset results if we change the target
					if (prevInput != input)
					{
						results.Clear();
						showResults = false;
					}
					if (GUILayout.Button("Find") && input != null)
					{
						searchMaterials = false;
						SearchProject(input);
					}
					break;
				}
				case SearchType.Material:
				{
					prevInput = input;
					input = EditorGUILayout.ObjectField(input, typeof(Material), false) as Material;
					// Reset results if we change the target
					if (prevInput != input)
					{
						results.Clear();
						showResults = false;
					}
					if (GUILayout.Button("Find") && input != null)
					{
						searchMaterials = false;
						SearchProject(input);
					}
					break;
				}
				case SearchType.Shader:
				{
					prevInput = input;
					input = EditorGUILayout.ObjectField(input, typeof(Shader), false) as Shader;
					// Reset results if we change the target
					if (prevInput != input)
					{
						results.Clear();
						showResults = false;
					}
					if (GUILayout.Button("Materials") && input != null)
					{
						searchMaterials = true;
						SearchProject(input);
					}
					if (GUILayout.Button("Prefabs") && input != null)
					{
						searchMaterials = false;
						SearchProject(input);
					}
					break;
				}
				case SearchType.Texture:
				{
					prevInput = input;
					input = EditorGUILayout.ObjectField(input, typeof(Texture), false) as Texture;
					// Reset results if we change the target
					if (prevInput != input)
					{
						results.Clear();
						showResults = false;
					}
					if (GUILayout.Button("Materials") && input != null)
					{
						searchMaterials = true;
						SearchProject(input);
					}
					if (GUILayout.Button("Prefabs") && input != null)
					{
						searchMaterials = false;
						SearchProject(input);
					}
					break;
				}
				case SearchType.Controller:
				{
					prevInput = input;
					input = EditorGUILayout.ObjectField(input, typeof(RuntimeAnimatorController), false) as RuntimeAnimatorController;
					// Reset results if we change the target
					if (prevInput != input)
					{
						results.Clear();
						showResults = false;
					}
					if (GUILayout.Button("Find") && input != null)
					{
						searchMaterials = false;
						SearchProject(input);
					}
					break;
				}
				case SearchType.Prefab:
				default:
				{
					prevInput = input;
					input = EditorGUILayout.ObjectField(input, typeof(Object), false);
					// Reset results if we change the target
					if (prevInput != input)
					{
						results.Clear();
						showResults = false;
					}
					if (GUILayout.Button("Find") && input != null)
					{
						searchMaterials = false;
						SearchProject(input);
					}
					break;
				}
			}

			if (GUILayout.Button("Clear"))
			{
				ClearAll();
			}
			EditorGUILayout.EndHorizontal();
		}


		private void SearchProject(Object selectedObject)
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
				// Nothing found
				if (results.Count == 0)
				{
					EditorGUILayout.HelpBox("No Occurrence Found", MessageType.Info);
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
				// Objects found
				else
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
			EditorGUILayout.EndScrollView();
		}
	}
}
