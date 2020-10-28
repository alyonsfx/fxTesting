using UnityEngine;
using UnityEditor;
using UnityEngine.U2D;

namespace PersonalEditorTools.Editor
{
	public class CreateThemes : EditorWindow
	{
		private string themeName;

		// private enum Folders
		// {
		// 	None = 0,
		// 	Animations = 1,
		// 	Materials = 1 << 1,
		// 	Prefabs = 1 << 2,
		// 	Textures = 1 << 3,
		// 	VFX = 1 << 4,
		// }
		//
		// private Folders selected;
		// private bool createAtlas = true;

		[MenuItem("Assets/Create Theme Folders")]
		public static void Open()
		{
			var window = GetWindow<CreateThemes>(true, "Create New Theme", true);
			window.maxSize = window.minSize = new Vector2(250, 75);
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
				Create();
			}
			EditorGUILayout.EndHorizontal();
			//
			// EditorGUILayout.BeginHorizontal();
			// selected = (Folders) EditorGUILayout.EnumFlagsField("Options", selected);
			// EditorGUILayout.EndHorizontal();
			//
			// EditorGUILayout.BeginHorizontal();
			// createAtlas = EditorGUILayout.ToggleLeft("Create Atlas", createAtlas);
			// EditorGUILayout.EndHorizontal();
		}

		private void Create()
		{
			var themeFolder = AssetDatabase.CreateFolder("Assets/Mino/Art/Themes", themeName);
			var themePath = AssetDatabase.GUIDToAssetPath(themeFolder);

			// if (((int) selected & (int) Folders.Animations) != 0)
			// {
			// 	AssetDatabase.CreateFolder(themePath, "Animations");
			// }
			//
			// if (((int) selected & (int) Folders.Materials) != 0)
			// {
			// 	AssetDatabase.CreateFolder(themePath, "Materials");
			// }

			// if (((int) selected & (int) Folders.Prefabs) != 0)
			// {
				// AssetDatabase.CreateFolder(themePath, "Prefabs");
			// }

			// if (((int) selected & (int) Folders.Textures) != 0)
			// {
				// var texturesFolder = AssetDatabase.CreateFolder(themePath, "Textures");
				// var texturePath = AssetDatabase.GUIDToAssetPath(texturesFolder);
				// AssetDatabase.CreateFolder(texturePath, "Background");
				// AssetDatabase.CreateFolder(texturePath, "Board");
				// AssetDatabase.CreateFolder(texturePath, "GarbageMarker");
				// AssetDatabase.CreateFolder(texturePath, "Minos");
				// AssetDatabase.CreateFolder(texturePath, "VFX");
				// if (createAtlas)
				// {
				// 	AssetDatabase.CreateAsset(new SpriteAtlas(), texturePath + "/" + themeName + "_Atlas.spriteatlas");
				// }
			// }
			//
			// if (((int) selected & (int) Folders.VFX) != 0)
			// {
			// 	AssetDatabase.CreateFolder(themePath, "VFX");
			// }

			AssetDatabase.CreateFolder(themePath, "Prefabs");
			var texturesFolder = AssetDatabase.CreateFolder(themePath, "Textures");
			var texturePath = AssetDatabase.GUIDToAssetPath(texturesFolder);
			AssetDatabase.CreateAsset(new SpriteAtlas(), texturePath + "/" + themeName + "_Atlas.spriteatlas");

			Close();
		}
	}
}
