// using System;
// using System.Collections.Generic;
// using System.IO;
// using N3twork.Mino.Engine;
// using N3twork.Mino.Theme.UberSystem;
// using UnityEngine;
// using UnityEditor;
// using Object = UnityEngine.Object;
//
// namespace N3twork.Mino.Theme
// {
// 	public class ThemeSetupTool : EditorWindow
// 	{
// 		private enum SetupOptions
// 		{
// 			Create,
// 			Assign,
// 			Skip
// 		};
//
// 		private string themeName;
// 		private string themeFolder;
// 		private string minoTextureFolder;
// 		private string prefabsFolder;
// 		private string tintFile;
// 		private TetrisThemeData themeData;
// 		private static readonly string[] Letters = {"I", "J", "L", "O", "S", "T", "Z", "G", "U"};
// 		private const string ThemesRoot = "Assets/AssetBundles/Themes/";
// 		private bool themeFolderError;
// 		private bool textureFolderError;
// 		private bool prefabFolderError;
//
// 		#region GUI
//
// 		private bool isError;
// 		private bool createMinos = true;
// 		private bool customMinoTextures = true;
// 		private bool tintMinos;
// 		private bool createGhost = true;
// 		private bool createPreview = true;
// 		private bool customPreviewTextures;
// 		private bool tintPreviews;
// 		// private bool useTextFile;
// 		private bool createData = true;
// 		private SetupOptions minoSetupType = SetupOptions.Assign;
// 		private SetupOptions behaviourSetupType = SetupOptions.Assign;
// 		private SetupOptions garbageMarkerSetupType = SetupOptions.Assign;
// 		private SetupOptions boardSetupType = SetupOptions.Assign;
// 		private bool setGenericData = true;
// 		private bool copyUiTints;
// 		private TetrisThemeData uiTintSource;
// 		private Color[] minoTints =
// 		{
// 			new Color(0.00f, 0.62f, 0.85f, 1.00f),//
// 			new Color(0.00f, 0.40f, 0.74f, 1.00f),//
// 			new Color(1.00f, 0.47f, 0.00f, 1.00f),//
// 			new Color(1.00f, 0.80f, 0.00f, 1.00f),//
// 			new Color(0.41f, 0.75f, 0.16f, 1.00f),//
// 			new Color(0.58f, 0.18f, 0.60f, 1.00f),//
// 			new Color(0.93f, 0.16f, 0.22f, 1.00f)//
// 		};
// 		private Color[] previewTints =
// 		{
// 			new Color(0.00f, 0.62f, 0.85f, 1.00f),//
// 			new Color(0.00f, 0.40f, 0.74f, 1.00f),//
// 			new Color(1.00f, 0.47f, 0.00f, 1.00f),//
// 			new Color(1.00f, 0.80f, 0.00f, 1.00f),//
// 			new Color(0.41f, 0.75f, 0.16f, 1.00f),//
// 			new Color(0.58f, 0.18f, 0.60f, 1.00f),//
// 			new Color(0.93f, 0.16f, 0.22f, 1.00f)//
// 		};
//
// 		[MenuItem("Tools/Theme Setup", false, 2)]
// 		public static void Open()
// 		{
// 			GetWindow<ThemeSetupTool>(true, "New Theme Setup", true);
// 		}
//
// 		private void OnGUI()
// 		{
// 			var nullStyle = new GUIStyle(GUI.skin.button) {normal = {textColor = new Color(0.2f,0.2f,0.2f,1f)}, fixedWidth = 150};
// 			var baseStyle = new GUIStyle(GUI.skin.button);
//
// 			var readyMino = (createGhost || createMinos || createPreview) && !string.IsNullOrEmpty(themeName);
// 			EditorGUIUtility.labelWidth = 166;
// 			EditorGUILayout.BeginHorizontal();
// 			themeName = EditorGUILayout.TextField("New Theme Name:", themeName);
// 			EditorGUILayout.EndHorizontal();
//
// 			ShowMinoOptions();
//
// 			EditorGUILayout.BeginHorizontal();
// 			GUILayout.FlexibleSpace();
// 			if (GUILayout.Button("Create Mino Prefabs", readyMino ? baseStyle : nullStyle))
// 			{
// 				if (string.IsNullOrEmpty(themeName))
// 				{
// 					L.Group("Theme Setup", "No theme name entered");
// 					isError = true;
// 				}
// 				else if (!readyMino)
// 				{
// 					L.Group("Theme Setup", "Select something to create");
// 					isError = true;
// 				}
// 				else
// 				{
// 					isError = prefabFolderError = textureFolderError = false;
// 					CreateMinos();
// 				}
// 			}
// 			GUILayout.FlexibleSpace();
// 			EditorGUILayout.EndHorizontal();
//
// 			ShowDataOptions();
//
// 			EditorGUILayout.BeginHorizontal();
// 			GUILayout.FlexibleSpace();
// 			var dataReady = !string.IsNullOrEmpty(themeName) && (createData || copyUiTints || behaviourSetupType != SetupOptions.Skip || boardSetupType != SetupOptions.Skip || garbageMarkerSetupType != SetupOptions.Skip || minoSetupType != SetupOptions.Skip);
// 			if (GUILayout.Button("Setup Theme Data", dataReady ? baseStyle : nullStyle))
// 			{
// 				if (string.IsNullOrEmpty(themeName))
// 				{
// 					L.Group("Theme Setup", "No theme name entered");
// 					isError = true;
// 				}
// 				else if (!dataReady)
// 				{
// 					L.Group("Theme Setup", "Check your settings");
// 				}
// 				else
// 				{
// 					isError = themeFolderError = prefabFolderError = textureFolderError = false;
// 					DataSetup();
// 				}
// 			}
// 			GUILayout.FlexibleSpace();
// 			EditorGUILayout.EndHorizontal();
//
// 			GUILayout.FlexibleSpace();
// 			EditorGUILayout.BeginHorizontal();
// 			EditorGUILayout.EndHorizontal();
//
// 			if (isError)
// 			{
// 				ShowError();
// 			}
// 		}
//
// 		private void ShowMinoOptions()
// 		{
// 			EditorGUILayout.BeginHorizontal();
// 			EditorGUILayout.LabelField("Setup Mino Prefabs");
// 			EditorGUILayout.EndHorizontal();
// 			EditorGUI.indentLevel++;
// 			EditorGUILayout.BeginHorizontal();
// 			createMinos = EditorGUILayout.Toggle("Create Minos", createMinos);
// 			EditorGUILayout.EndHorizontal();
//
// 			if (createMinos)
// 			{
// 				EditorGUI.indentLevel++;
// 				EditorGUILayout.BeginHorizontal();
// 				customMinoTextures = EditorGUILayout.Toggle("Use Unique Textures", customMinoTextures);
// 				EditorGUILayout.EndHorizontal();
// 				EditorGUILayout.BeginHorizontal();
// 				tintMinos = EditorGUILayout.Toggle("Tint Renderer", tintMinos);
// 				EditorGUILayout.EndHorizontal();
// 				EditorGUI.indentLevel--;
// 				if (tintMinos)
// 				{
// 					EditorGUILayout.BeginHorizontal();
// 					ShowLetterTint(false);
// 					EditorGUILayout.EndHorizontal();
// 				}
// 				EditorGUILayout.BeginHorizontal();
// 				EditorGUILayout.HelpBox(
// 					$"Looking for {themeName}-MinoX, {themeName}-MinoGhost, & {themeName}-MinoPreview{Environment.NewLine}" +
// 					"If each mino has it's own texture select Use Unique Textures{Environment.NewLine}" +
// 					"If minos share the same texture, tint them via Tint Renderer",
// 					customMinoTextures && tintMinos ? MessageType.Warning : MessageType.Info);
// 				EditorGUILayout.EndHorizontal();
// 			}
//
// 			EditorGUILayout.BeginHorizontal();
// 			createPreview = EditorGUILayout.Toggle("Create Preview Minos", createPreview);
// 			EditorGUILayout.EndHorizontal();
// 			if (createPreview)
// 			{
// 				EditorGUI.indentLevel++;
// 				EditorGUILayout.BeginHorizontal();
// 				customPreviewTextures = EditorGUILayout.Toggle("Unique Preview Textures", customPreviewTextures);
// 				EditorGUILayout.EndHorizontal();
// 				EditorGUILayout.BeginHorizontal();
// 				tintPreviews = EditorGUILayout.Toggle("Tint Preview", tintPreviews);
// 				EditorGUILayout.EndHorizontal();
// 				EditorGUI.indentLevel--;
// 				if (tintPreviews)
// 				{
// 					ShowLetterTint(true);
// 				}
//
// 				EditorGUILayout.BeginHorizontal();
// 				EditorGUILayout.HelpBox(
// 					$"If each preview mino has it's own texture select Use Unique Textures{Environment.NewLine}" +
// 					"If preview minos share the same texture, tint them via Tint Renderer",
// 					customMinoTextures && tintMinos ? MessageType.Warning : MessageType.Info);
// 				EditorGUILayout.EndHorizontal();
// 			}
//
// 			EditorGUILayout.BeginHorizontal();
// 			createGhost = EditorGUILayout.Toggle("Create Ghost", createGhost);
// 			EditorGUILayout.EndHorizontal();
// 			EditorGUI.indentLevel--;
// 		}
//
// 		private void ShowLetterTint(bool isPreview)
// 		{
// 			EditorGUIUtility.labelWidth = 33;
// 			for (var index = 0; index < 7; index++)
// 			{
// 				EditorGUILayout.BeginHorizontal();
// 				if (isPreview)
// 				{
// 					previewTints[index] = EditorGUILayout.ColorField($"{Letters[index]} Preview Tint", previewTints[index]);
// 				}
// 				else
// 				{
// 					minoTints[index] = EditorGUILayout.ColorField($"{Letters[index]} Tint", minoTints[index]);
// 				}
//
// 				EditorGUILayout.EndHorizontal();
// 			}
//
// 			EditorGUIUtility.labelWidth = 100;
// 		}
//
// 		private void ShowDataOptions()
// 		{
// 			EditorGUILayout.BeginHorizontal();
// 			EditorGUILayout.LabelField("Setup Theme Data");
// 			EditorGUI.indentLevel++;
// 			EditorGUILayout.EndHorizontal();
// 			EditorGUILayout.BeginHorizontal();
// 			createData = EditorGUILayout.Toggle("Create Data", createData);
// 			EditorGUILayout.EndHorizontal();
// 			EditorGUILayout.BeginHorizontal();
// 			minoSetupType = (SetupOptions)EditorGUILayout.EnumPopup("Mino Setup", minoSetupType);
// 			EditorGUILayout.EndHorizontal();
// 			EditorGUILayout.BeginHorizontal();
// 			behaviourSetupType = (SetupOptions)EditorGUILayout.EnumPopup("Behaviour Setup", behaviourSetupType);
// 			EditorGUILayout.EndHorizontal();
// 			EditorGUILayout.BeginHorizontal();
// 			boardSetupType = (SetupOptions)EditorGUILayout.EnumPopup("Board Setup", boardSetupType);
// 			EditorGUILayout.EndHorizontal();
// 			EditorGUILayout.BeginHorizontal();
// 			garbageMarkerSetupType = (SetupOptions)EditorGUILayout.EnumPopup("Garbage Marker Setup", garbageMarkerSetupType);
// 			EditorGUILayout.EndHorizontal();
// 			EditorGUILayout.BeginHorizontal();
// 			setGenericData = EditorGUILayout.Toggle("Assign generic data", setGenericData);
// 			EditorGUILayout.EndHorizontal();
// 			EditorGUILayout.BeginHorizontal();
// 			copyUiTints = EditorGUILayout.Toggle("Copy UI Tint Values", copyUiTints);
// 			EditorGUILayout.EndHorizontal();
// 			if (copyUiTints)
// 			{
// 				uiTintSource = (TetrisThemeData)EditorGUILayout.ObjectField(uiTintSource, typeof(TetrisThemeData), false);
// 			}
// 			EditorGUI.indentLevel--;
// 		}
//
// 		private void ShowError()
// 		{
// 			EditorGUILayout.Space();
// 			EditorGUILayout.Space();
// 			EditorGUILayout.HelpBox("Encountered a problem. Please check the console.", MessageType.Error, true);
// 		}
//
// 		#endregion
//
// 		private void FolderSetup()
// 		{
// 			themeFolder = $"{ThemesRoot}{themeName}/";
// 			if (!Directory.Exists(themeFolder))
// 			{
// 				L.Group("Theme Setup","That theme folder doesn't exist!!");
// 				isError = true;
// 				themeFolder = null;
// 				return;
// 			}
//
// 			minoTextureFolder = themeFolder + "Textures/Minos/";
// 			if (!Directory.Exists(minoTextureFolder))
// 			{
// 				L.Group("Theme Setup","That mino texture folder doesn't exist!!");
// 				isError = true;
// 				themeFolder = null;
// 				return;
// 			}
//
// 			prefabsFolder = themeFolder + "Prefabs/";
// 			if (!Directory.Exists(prefabsFolder))
// 			{
// 				L.Group("Theme Setup","That prefabs folder doesn't exist!!");
// 				isError = true;
// 				themeFolder = null;
// 			}
// 		}
//
// 		// OLD: not needed for vendor themes
// 		// private void CreateFolders()
// 		// {
// 		// 	var themeFolder = AssetDatabase.CreateFolder("Assets/Mino/Art/Themes", themeName);
// 		// 	var themePath = AssetDatabase.GUIDToAssetPath(themeFolder);
// 		// 	AssetDatabase.CreateFolder(themePath, "Prefabs");
// 		// 	var texturesFolder = AssetDatabase.CreateFolder(themePath, "Textures");
// 		// 	var texturePath = AssetDatabase.GUIDToAssetPath(texturesFolder);
// 		// 	AssetDatabase.CreateAsset(new SpriteAtlas(), texturePath + "/" + themeName + "_Atlas.spriteatlas");
// 		// }
//
// 		#region Minos
//
// 		private void CreateMinos()
// 		{
// 			FolderSetup();
// 			if (themeFolderError || textureFolderError || prefabFolderError)
// 			{
// 				return;
// 			}
//
// 			// if (useTextFile)
// 			// {
// 			// 	ReadTextFile();
// 			// }
//
// 			if (createMinos)
// 			{
// 				CreateBaseMino();
// 			}
//
// 			if (createPreview)
// 			{
// 				CreateBasePreview();
// 			}
//
// 			if (createGhost)
// 			{
// 				CreateGhostMino();
// 			}
// 		}
//
// 		// TODO: Set this up
// 		// private void ReadTextFile()
// 		// {
// 		// 	var files = Directory.GetFiles(minoTextureFolder, "*.txt");
// 		// 	if (files.Length == 0)
// 		// 	{
// 		// 		L.Group("Theme Setup","No text files found");
// 		// 		return;
// 		// 	}
// 		//
// 		// 	var lines = File.ReadAllLines(files[0]);
// 		// 	for (var index = 0; index < lines.Length; index++)
// 		// 	{
// 		// 		var line = lines[index];
// 		// 		L.Group("Theme Setup",$"Line {index + 1}: {line}");
// 		// 		var hexValue = "#" + line.Substring(line.Length - 6).ToUpper();
// 		// 		L.Group("Theme Setup",$"Code is: {hexValue}");
// 		//
// 		// 		ColorUtility.TryParseHtmlString(hexValue, out var newCol);
// 		// 		previewTints[index] = newCol;
// 		// 		L.Group("Theme Setup",$"Color {index}: {hexValue} : {newCol}");
// 		// 	}
// 		// }
//
// 		private void CreateBaseMino()
// 		{
// 			var createAll = customMinoTextures || tintMinos;
// 			var initialName = createAll ? Letters[0] : "";
// 			var baseObject = new GameObject {name = $"{themeName}-Mino{initialName}"};
// 			// var minoObject = baseObject.AddComponent<UberMonominoObject>();
// 			var minoObject = baseObject.AddComponent<UberMonominoObject>();
//
// 			var mino = new GameObject {name = "Mino"};
// 			var renderer = mino.AddComponent<SpriteRenderer>();
// 			renderer.transform.parent = baseObject.transform;
// 			var spritePath = $"{minoTextureFolder}{themeName}-Mino{initialName}.png";
// 			if (File.Exists(spritePath))
// 			{
// 				renderer.sprite = (Sprite) AssetDatabase.LoadAssetAtPath(spritePath, typeof(Sprite));
// 			}
// 			else
// 			{
// 				L.Group("Theme Setup", "That mino texture doesn't exist!!");
// 				isError = true;
// 			}
//
// 			if (tintMinos)
// 			{
// 				renderer.color = minoTints[0];
// 			}
// 			var order = mino.AddComponent<SpriteOrder>();
//
// 			minoObject.NewThemeSetup(renderer);
// 			order.NewThemeSetup(0);
//
// 			var localPath = $"{prefabsFolder}{baseObject.name}.prefab";
// 			var main = PrefabUtility.SaveAsPrefabAssetAndConnect(baseObject, localPath, InteractionMode.AutomatedAction);
// 			L.Group("Theme Setup",$"{baseObject.name} prefab created");
// 			DestroyImmediate(baseObject);
//
// 			if (createAll)
// 			{
// 				CreateMinoVariants(main);
// 			}
// 		}
//
// 		private void CreateMinoVariants(Object baseMino)
// 		{
// 			for (var i = 1; i < Letters.Length; i++)
// 			{
// 				var newPrefab = (GameObject) PrefabUtility.InstantiatePrefab(baseMino);
// 				newPrefab.name = $"{themeName}-Mino{Letters[i]}";
// 				var spriteRenderer = newPrefab.GetComponentInChildren<SpriteRenderer>();
// 				if (tintMinos)
// 				{
// 					spriteRenderer.color = minoTints[i];
// 				}
// 				else
// 				{
// 					var spritePath = $"{minoTextureFolder}{newPrefab.name}.png";
// 					if(File.Exists(spritePath))
// 					{
// 						spriteRenderer.sprite = (Sprite) AssetDatabase.LoadAssetAtPath(spritePath, typeof(Sprite));
// 					}
// 					else
// 					{
// 						L.Group("Theme Setup", "That mino texture doesn't exist!!");
// 						isError = true;
// 					}
// 				}
// 				PrefabUtility.SaveAsPrefabAssetAndConnect(newPrefab, $"{prefabsFolder}{newPrefab.name}.prefab", InteractionMode.AutomatedAction);
// 				L.Group("Theme Setup",$"{newPrefab.name} prefab created");
// 				DestroyImmediate(newPrefab);
// 			}
// 		}
//
// 		private void CreateGhostMino()
// 		{
// 			var baseObject = new GameObject {name = $"{themeName}-MinoGhost"};
// 			baseObject.AddComponent<MonominoObject>();
//
// 			var mino = new GameObject {name = "Mino"};
// 			var renderer = mino.AddComponent<SpriteRenderer>();
// 			renderer.transform.parent = baseObject.transform;
// 			renderer.sprite = (Sprite) AssetDatabase.LoadAssetAtPath($"{minoTextureFolder}{themeName}-MinoGhost.png", typeof(Sprite));
// 			var order = mino.AddComponent<SpriteOrder>();
// 			order.NewThemeSetup(-1);
//
// 			var localPath = $"{prefabsFolder}{baseObject.name}.prefab";
// 			PrefabUtility.SaveAsPrefabAssetAndConnect(baseObject, localPath, InteractionMode.AutomatedAction);
// 			L.Group("Theme Setup",$"{baseObject.name} prefab created");
// 			DestroyImmediate(baseObject);
// 		}
//
// 		private void CreateBasePreview()
// 		{
// 			var createAll = customPreviewTextures || tintPreviews;
// 			var textureName = createAll ? $"{themeName}-Mino{Letters[0]}-Preview" : $"{themeName}-MinoPreview";
// 			var baseObject = new GameObject {name = textureName};
// 			baseObject.AddComponent<MonominoObject>();
//
// 			var renderer = new GameObject {name = "Mino"}.AddComponent<SpriteRenderer>();
// 			renderer.transform.parent = baseObject.transform;
// 			var spritePath = $"{minoTextureFolder}{baseObject.name}.png";
// 			if (File.Exists(spritePath))
// 			{
// 				renderer.sprite = (Sprite) AssetDatabase.LoadAssetAtPath(spritePath, typeof(Sprite));
// 			}
// 			if (tintPreviews)
// 			{
// 				renderer.color = previewTints[0];
// 			}
//
// 			var localPath = $"{prefabsFolder}{baseObject.name}.prefab";
// 			var main = PrefabUtility.SaveAsPrefabAssetAndConnect(baseObject, localPath, InteractionMode.AutomatedAction);
// 			L.Group("Theme Setup",$"{baseObject.name} prefab created");
// 			DestroyImmediate(baseObject);
// 			if (createAll)
// 			{
// 				CreatePreviewVariants(main);
// 			}
// 		}
//
// 		private void CreatePreviewVariants(Object basePreview)
// 		{
// 			for (var i = 1; i < 7; i++)
// 			{
// 				var newPreview = (GameObject) PrefabUtility.InstantiatePrefab(basePreview);
// 				newPreview.name = $"{themeName}-Mino{Letters[i]}-Preview";
// 				var spriteRenderer = newPreview.GetComponentInChildren<SpriteRenderer>();
// 				if (tintPreviews)
// 				{
// 					spriteRenderer.color = previewTints[i];
// 				}
// 				else
// 				{
// 					var spritePath = $"{minoTextureFolder}{newPreview.name}.png";
// 					if (File.Exists(spritePath))
// 					{
// 						spriteRenderer.sprite = (Sprite) AssetDatabase.LoadAssetAtPath(spritePath, typeof(Sprite));
// 					}
// 				}
//
// 				PrefabUtility.SaveAsPrefabAssetAndConnect(newPreview, $"{prefabsFolder}{newPreview.name}.prefab", InteractionMode.AutomatedAction);
// 				L.Group("Theme Setup",$"{newPreview.name} prefab created");
// 				DestroyImmediate(newPreview);
// 			}
// 		}
//
// 		#endregion
//
// 		#region Data
//
// 		private void DataSetup()
// 		{
// 			L.Group("Theme Setup", "Data setup started!");
// 			FolderSetup();
// 			if (themeFolder == null)
// 			{
// 				L.Group("Theme Setup", "Theme directory not found");
// 				isError = true;
// 				return;
// 			}
// 			SetupThemeData();
// 			if (minoSetupType == SetupOptions.Create)
// 			{
// 				if (createMinos)
// 				{
// 					CreateBaseMino();
// 				}
//
// 				if (createPreview)
// 				{
// 					CreateBasePreview();
// 				}
//
// 				if (createGhost)
// 				{
// 					CreateGhostMino();
// 				}
// 			}
//
// 			if(behaviourSetupType != SetupOptions.Skip)
// 			{
// 				SetupBehaviour();
// 			}
// 			if (boardSetupType != SetupOptions.Skip)
// 			{
// 				SetBoard();
// 			}
// 			if (garbageMarkerSetupType != SetupOptions.Skip)
// 			{
// 				SetupGarbageMarker();
// 			}
//
// 			if (setGenericData)
// 			{
// 				SetupSharedObjects();
// 			}
//
// 			if (minoSetupType != SetupOptions.Skip)
// 			{
// 				SetAllTetrominos();
// 			}
// 			EditorUtility.SetDirty(themeData);
// 		}
//
// 		private void SetupThemeData()
// 		{
// 			var targetPath = $"{themeFolder}{themeName}Theme.asset";
// 			if (File.Exists(targetPath))
// 			{
// 				themeData = AssetDatabase.LoadAssetAtPath<TetrisThemeData>(targetPath);
// 				L.Group("Theme Setup", "Existing theme data found");
// 			}
// 			else
// 			{
// 				themeData = CreateInstance<TetrisThemeData>();
// 				AssetDatabase.CreateAsset(themeData, targetPath);
// 				AssetDatabase.SaveAssets();
// 				L.Group("Theme Setup", "Theme data created");
// 			}
//
// 			if (copyUiTints)
// 			{
// 				CloneUITints();
// 			}
// 			Selection.activeObject = themeData;
// 		}
//
// 		private void CloneUITints()
// 		{
// 			if (uiTintSource == null)
// 			{
// 				L.Group("Theme Setup", "No source theme to copy from");
// 				isError = true;
// 			}
// 			else
// 			{
// 				var temp = new MinigameUITintGroup
// 				{
// 					containerTints = new RoyaleContainerTints
// 					{
// 						attackerFill = uiTintSource.MinigameUITint.containerTints.attackerFill,
// 						attackerListFill = uiTintSource.MinigameUITint.containerTints.attackerListFill,
// 						attackerStroke = uiTintSource.MinigameUITint.containerTints.attackerStroke,
// 						queueFill = uiTintSource.MinigameUITint.containerTints.queueFill,
// 						queueStroke = uiTintSource.MinigameUITint.containerTints.queueStroke,
// 						shadow = uiTintSource.MinigameUITint.containerTints.shadow,
// 						targetFill = uiTintSource.MinigameUITint.containerTints.targetFill,
// 						targetHeader = uiTintSource.MinigameUITint.containerTints.targetHeader,
// 						targetStroke = uiTintSource.MinigameUITint.containerTints.targetStroke,
// 						trayFill = uiTintSource.MinigameUITint.containerTints.trayFill
// 					},
// 					previewBoardColors = new RoyalePreviewBoardColors
// 					{
// 						boardColor = new Color(0.2f, 0.2f, 0.2f, 1f),
// 						iMinoColor = minoTints[0],
// 						jMinoColor = minoTints[1],
// 						lMinoColor = minoTints[2],
// 						oMinoColor = minoTints[3],
// 						sMinoColor = minoTints[4],
// 						tMinoColor = minoTints[5],
// 						zMinoColor = minoTints[6],
// 						gMinoColor = Color.gray,
// 						uMinoColor = Color.white
// 					},
// 					timerColors = new MinigameTimerColors {timerBackground = uiTintSource.MinigameUITint.timerColors.timerBackground, timerFill = uiTintSource.MinigameUITint.timerColors.timerFill, timerTextDanger = uiTintSource.MinigameUITint.timerColors.timerTextDanger, timerTextFrenzy = uiTintSource.MinigameUITint.timerColors.timerTextFrenzy}
// 				};
// 				themeData.SetTints(temp);
// 				L.Group("Theme Setup", "UI Tints copied");
// 			}
// 		}
//
// 		private void SetupBehaviour()
// 		{
// 			var targetPath = $"{themeFolder}{themeName}Behaviour.asset";
// 			if (File.Exists(targetPath))
// 			{
// 				themeData.SetBehaviour((TetrisThemeBehaviour) AssetDatabase.LoadAssetAtPath(targetPath, typeof(TetrisThemeBehaviour)));
// 				L.Group("Theme Setup", behaviourSetupType == SetupOptions.Assign ? "Theme behaviour connected" : "Existing theme behaviour found and connected");
// 			}
// 			else
// 			{
// 				if (behaviourSetupType == SetupOptions.Assign)
// 				{
// 					L.Group("Theme Setup", "No theme behaviour found and you didn't want to create one?");
// 					isError = true;
// 				}
// 				else if (behaviourSetupType == SetupOptions.Create)
// 				{
// 					var behaviour = CreateInstance<UberThemeBehaviour>();
// 					AssetDatabase.CreateAsset(behaviour, targetPath);
// 					AssetDatabase.SaveAssets();
// 					L.Group("Theme Setup", "Theme behaviour created");
// 					themeData.SetBehaviour((TetrisThemeBehaviour) AssetDatabase.LoadAssetAtPath(targetPath, typeof(TetrisThemeBehaviour)));
// 					L.Group("Theme Setup", "Theme behaviour connected");
// 				}
// 			}
// 		}
//
// 		private void SetBoard()
// 		{
// 			var targetPath = $"{prefabsFolder}{themeName}-Board.prefab";
// 			if (!File.Exists(targetPath))
// 			{
// 				L.Group("Theme Setup","Board prefab not found!");
// 				isError = true;
// 				return;
// 			}
//
// 			var board = (GameObject) AssetDatabase.LoadAssetAtPath(targetPath, typeof(GameObject));
// 			if (boardSetupType == SetupOptions.Create)
// 			{
// 				L.Group("Theme Setup","Adding board component");
// 				board.AddComponent<UberBoardObject>();
// 			}
// 			themeData.SetBoard(board.GetComponent<BoardObject>());
// 			L.Group("Theme Setup","Board connected");
// 		}
//
// 		private void SetupSharedObjects()
// 		{
// 			var ghost = new GhostThemeData();
// 			var ghostTetrominoPath = "Assets/Mino/Art/Themes/Shared/Prefabs/Shared_GhostObject.prefab";
// 			if (!File.Exists(ghostTetrominoPath))
// 			{
// 				L.Group("Theme Setup","Ghost tetromino prefab not found!");
// 				isError = true;
// 				return;
// 			}
//
// 			var ghostMinoPath = $"{prefabsFolder}{themeName}-MinoGhost.prefab";
// 			if (!File.Exists(ghostMinoPath))
// 			{
// 				L.Group("Theme Setup","Ghost monomino prefab not found!");
// 				isError = true;
// 				return;
// 			}
// 			ghost.Setup((TetrominoObject) AssetDatabase.LoadAssetAtPath(ghostTetrominoPath, typeof(TetrominoObject)), (MonominoObject) AssetDatabase.LoadAssetAtPath(ghostMinoPath, typeof(MonominoObject)));
// 			themeData.SetDefaults((TetrominoObject) AssetDatabase.LoadAssetAtPath("Assets/Mino/Art/Themes/Shared/Prefabs/Shared_TetrominoBase.prefab", typeof(TetrominoObject)), ghost);
// 			L.Group("Theme Setup","Default objects created connected");
// 		}
//
// 		private void SetupGarbageMarker()
// 		{
// 			var targetPath = $"{prefabsFolder}{themeName}-GarbageMarker.prefab";
// 			if (File.Exists(targetPath))
// 			{
// 				var prefab = (GameObject) AssetDatabase.LoadAssetAtPath(targetPath, typeof(GameObject));
// 				AssignGarbageMarker(prefab);
// 				L.Group("Theme Setup", garbageMarkerSetupType == SetupOptions.Assign ? "Garbage marker connected" : "Existing garbage marker found and connected");
// 			}
// 			else
// 			{
// 				if (garbageMarkerSetupType == SetupOptions.Assign)
// 				{
// 					L.Group("Theme Setup", "No garbage marker found and you didn't want to create one?");
// 					isError = true;
// 				}
// 				else if (garbageMarkerSetupType == SetupOptions.Create)
// 				{
// 					var template = AssetDatabase.LoadAssetAtPath("Assets/Mino/Art/Themes/Shared/Prefabs/Template_GarbageMarker.prefab", typeof(object));
// 					var marker = (GameObject) PrefabUtility.InstantiatePrefab(template);
// 					var prefab = PrefabUtility.SaveAsPrefabAssetAndConnect(marker, targetPath, InteractionMode.AutomatedAction);
// 					DestroyImmediate(marker);
// 					AssignGarbageMarker(prefab);
// 					L.Group("Theme Setup", "Garbage marker created & connected");
// 				}
// 			}
// 		}
//
// 		private void AssignGarbageMarker(GameObject prefab)
// 		{
// 			var garbageMarker = new GarbageMarkerThemeData();
// 			garbageMarker.Setup(prefab.GetComponent<PrimetimeGarbageMarkerController>(), prefab.GetComponent<RoyaleGarbageMarkerController>());
// 			themeData.SetGarbageMarker(garbageMarker);
// 		}
//
// 		private void SetAllTetrominos()
// 		{
// 			var tetrominos = new List<TetrominoThemeData>();
// 			for (var i = 0; i < Letters.Length; i++)
// 			{
// 				var tetrominoData = new TetrominoThemeData();
// 				var mino = GetMino(Letters[i]);
// 				var preview = GetPreviewMino(Letters[i]);
// 				foreach (var tetrominoLetter in (TetrominoLetter[]) Enum.GetValues(typeof(TetrominoLetter)))
// 				{
// 					var letter = tetrominoLetter.ToString();
// 					if (string.Equals(Letters[i], letter, StringComparison.OrdinalIgnoreCase))
// 					{
// 						tetrominoData.Setup(tetrominoLetter, mino, preview);
// 						tetrominos.Add(tetrominoData);
// 					}
// 				}
// 				L.Group("Theme Setup",$"{Letters[i]} tetromino data created");
// 			}
// 			themeData.SetTetrominos(tetrominos);
// 			L.Group("Theme Setup",$"Tetromino data connected");
// 		}
//
// 		private MonominoObject GetMino(string letter)
// 		{
// 			MonominoObject minoObject;
// 			if (File.Exists($"{prefabsFolder}{themeName}-Mino{letter}.prefab"))
// 			{
// 				minoObject = (MonominoObject) AssetDatabase.LoadAssetAtPath($"{prefabsFolder}{themeName}-Mino{letter}.prefab", typeof(MonominoObject));
// 			}
// 			else
// 			{
// 				minoObject = (MonominoObject) AssetDatabase.LoadAssetAtPath($"{prefabsFolder}{themeName}-Mino.prefab", typeof(MonominoObject));
// 			}
//
// 			return minoObject;
// 		}
//
// 		private MonominoObject GetPreviewMino(string letter)
// 		{
// 			MonominoObject minoObject;
// 			if (File.Exists($"{prefabsFolder}{themeName}-Mino{letter}-Preview.prefab"))
// 			{
// 				minoObject = (MonominoObject) AssetDatabase.LoadAssetAtPath($"{prefabsFolder}{themeName}-Mino{letter}-Preview.prefab", typeof(MonominoObject));
// 			}
// 			else
// 			{
// 				minoObject = (MonominoObject) AssetDatabase.LoadAssetAtPath($"{prefabsFolder}{themeName}-Mino-Preview.prefab", typeof(MonominoObject));
// 			}
//
// 			return minoObject;
// 		}
//
// 		// TODO: Read text file with UI Tint colors
//
// 		#endregion
// 	}
// }