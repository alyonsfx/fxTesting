using N3twork.Mino;
using UnityEngine;
using UnityEditor;

namespace PersonalEditorTools.Editor
{
	public class CreateMinoPrefabs : EditorWindow
	{
		private string themeName;
		private string textureFolder;
		private string prefabsFolder;
		private bool createFullSet;
		private bool createGarbage;
		private bool createGhost;
		private static readonly string[] letters = new[] {"I", "J", "L", "O", "S", "T", "Z", "G", "U"};

		[MenuItem("Assets/Create Mino Prefabs")]
		public static void Open()
		{
			var window = GetWindow<CreateMinoPrefabs>(true, "Create Mino Prefabs", true);
			window.maxSize = window.minSize = new Vector2(250, 150);
		}

		private void OnGUI()
		{
			EditorGUIUtility.labelWidth = 100;
			EditorGUILayout.BeginHorizontal();
			themeName = EditorGUILayout.TextField("New Theme Name:", themeName);
			EditorGUILayout.EndHorizontal();

			EditorGUILayout.BeginHorizontal();
			if (GUILayout.Button("Create"))
			{
				FindTextures();
			}
			EditorGUILayout.EndHorizontal();

			EditorGUILayout.BeginHorizontal();
			createFullSet = EditorGUILayout.ToggleLeft("Full Set", createFullSet);
			EditorGUILayout.EndHorizontal();

			if (!createFullSet)
			{
				EditorGUILayout.BeginHorizontal();
				createGarbage = EditorGUILayout.ToggleLeft("Create Garbage", createGarbage);
				EditorGUILayout.EndHorizontal();
			}

			EditorGUILayout.BeginHorizontal();
			createGhost = EditorGUILayout.ToggleLeft("Full Ghost", createGhost);
			EditorGUILayout.EndHorizontal();
		}

		private void FindTextures()
		{
			var themePath = "Assets/Mino/Art/Themes/"+themeName;
			textureFolder = themePath + "/Textures/Minos/";
			prefabsFolder = themePath + "/Prefabs/";
			CreateMainMino();

		}

		private void CreateMainMino()
		{
			var initialName = createFullSet ? letters[0] : "";
			var baseObject = new GameObject {name = themeName + "_Mino" + initialName};
			var mObject = baseObject.AddComponent<ResettableMonominoObject>();

			var mino = new GameObject {name = "Mino"};
			var renderer = mino.AddComponent<SpriteRenderer>();
			mObject.NewThemeSetup(renderer);
			renderer.transform.parent = baseObject.transform;
			renderer.sprite = (Sprite)AssetDatabase.LoadAssetAtPath(textureFolder + themeName + "_Mino" + initialName + ".png", typeof(Sprite));
			var order = mino.AddComponent<SpriteOrder>();
			order.NewThemeSetup(0);

			var localPath = prefabsFolder + baseObject.name + ".prefab";
			var main = PrefabUtility.SaveAsPrefabAssetAndConnect(baseObject,localPath,InteractionMode.AutomatedAction);

			if (createFullSet || createGarbage)
			{
				CreateMinoVariants(main);
			}
			DestroyImmediate(main);
		}

		private void CreateMinoVariants(Object main)
		{
			if (createFullSet)
			{
				for (var i = 1; i < letters.Length; i++)
				{
					var next = (GameObject) PrefabUtility.InstantiatePrefab(main);
					var oldName = main.name;
					next.name = oldName.Remove(oldName.Length - 1, 1)+letters[i];
					next.GetComponentInChildren<SpriteRenderer>().sprite = (Sprite) AssetDatabase.LoadAssetAtPath(textureFolder + themeName + "_Mino"+letters[i]+".png", typeof(Sprite));
					PrefabUtility.SaveAsPrefabAssetAndConnect(next, prefabsFolder + next.name + ".prefab", InteractionMode.AutomatedAction);
					DestroyImmediate(next);
				}
			}
			else
			{
				for (var i = 7; i < letters.Length; i++)
				{
					var next = (GameObject) PrefabUtility.InstantiatePrefab(main);
					var oldName = main.name;
					next.name = oldName.Remove(oldName.Length - 1, 1) + letters[i];
					next.GetComponentInChildren<SpriteRenderer>().sprite = (Sprite) AssetDatabase.LoadAssetAtPath(textureFolder + themeName + "_Mino" + letters[i] + ".png", typeof(Sprite));
					PrefabUtility.SaveAsPrefabAssetAndConnect(next, prefabsFolder + next.name + ".prefab", InteractionMode.AutomatedAction);
					DestroyImmediate(next);
				}
			}

			if (createGhost)
			{
				CreateGhostMino();
			}
			Close();
		}

		private void CreateGhostMino()
		{
			var baseObject = new GameObject {name = themeName + "_MinoGhost"};
			baseObject.AddComponent<MonominoObject>();

			var mino = new GameObject {name = "Mino"};
			var renderer = mino.AddComponent<SpriteRenderer>();
			renderer.transform.parent = baseObject.transform;
			renderer.sprite = (Sprite) AssetDatabase.LoadAssetAtPath(textureFolder + themeName + "_MinoGhost.png", typeof(Sprite));
			var order = mino.AddComponent<SpriteOrder>();
			order.NewThemeSetup(-1);

			var localPath = prefabsFolder + baseObject.name + ".prefab";
			var main = PrefabUtility.SaveAsPrefabAssetAndConnect(baseObject, localPath, InteractionMode.AutomatedAction);
			DestroyImmediate(main);
		}
	}
}