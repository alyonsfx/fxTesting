using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;

public class BossToolset : EditorWindow
{
	private string newName;
	private string folderPath;
	private bool noName;
	private readonly List<string> results = new List<string>();
	private string fileName;
	private bool foundBosses;
	private Vector2 resultsScroll;
	private bool editingBoss;
	private BossData currentBoss;
	private bool initialized;
	private int level;
	private float attackPower;
	private float attackSpeed;
	private float critChance;
	private float health;
	private float defense;

	[MenuItem("Tools/Boss Toolset")]
	public static void Open()
	{
		var window = GetWindow<BossToolset>(false, "Boss Toolset", true);
		window.position = new Rect(Screen.width / 2f, Screen.height / 2f, 500f, 500f);
	}

	private void OnGUI()
	{
		var titleStyle = new GUIStyle(GUI.skin.label) {alignment = TextAnchor.MiddleCenter, fontSize = 14};
		var subTitleStyleA = new GUIStyle(GUI.skin.label) {alignment = TextAnchor.MiddleRight};
		var subTitleStyleB = new GUIStyle(GUI.skin.label) {alignment = TextAnchor.MiddleLeft, normal = {textColor = Color.red}};
		var editStyle = new GUIStyle(GUI.skin.button) {normal = {textColor = Color.red}, active = {textColor = Color.black}, fixedWidth = 150};
		var createStyle = new GUIStyle(GUI.skin.button) {normal = {textColor = Color.green}, active = {textColor = Color.black}, fixedWidth = 150};

		EditorGUILayout.LabelField("Create New Boss", titleStyle);
		EditorGUILayout.Space();

		EditorGUILayout.BeginHorizontal();
		newName = EditorGUILayout.TextField("New Boss Name", newName);
		EditorGUILayout.EndHorizontal();

		EditorGUILayout.Space();
		EditorGUILayout.BeginHorizontal();
		GUILayout.FlexibleSpace();
		if (GUILayout.Button("Create", createStyle))
		{
			Setup();
		}
		GUILayout.FlexibleSpace();
		EditorGUILayout.EndHorizontal();

		if (noName)
		{
			EditorGUILayout.BeginHorizontal();
			EditorGUILayout.HelpBox("Enter a name for your boss", MessageType.Info);
			EditorGUILayout.EndHorizontal();
		}

		EditorGUILayout.Space();
		EditorGUILayout.Space();
		EditorGUILayout.Space();
		EditorGUILayout.BeginHorizontal();
		EditorGUILayout.LabelField("Find Bosses", titleStyle);
		EditorGUILayout.EndHorizontal();

		EditorGUILayout.BeginHorizontal();
		EditorGUILayout.LabelField("Bosses Found: " + results.Count, new GUIStyle(GUI.skin.label) {alignment = TextAnchor.MiddleCenter});
		EditorGUILayout.EndHorizontal();

		EditorGUILayout.BeginHorizontal();
		GUILayout.FlexibleSpace();
		if (GUILayout.Button("Search Project", new GUIStyle(GUI.skin.button) {fixedWidth = 150}))
		{
			SearchProject();
		}

		GUILayout.FlexibleSpace();
		EditorGUILayout.EndHorizontal();

		EditorGUILayout.Space();
		EditorGUILayout.BeginHorizontal();
		if (foundBosses)
		{
			ShowObjects();
		}
		EditorGUILayout.EndHorizontal();

		EditorGUILayout.Space();
		EditorGUILayout.Space();
		EditorGUILayout.BeginHorizontal();
		EditorGUILayout.LabelField("Edit Boss", titleStyle);
		EditorGUILayout.EndHorizontal();

		EditorGUILayout.Space();
		if (editingBoss)
		{
			EditorGUILayout.BeginHorizontal();
			EditorGUILayout.BeginVertical();
			EditorGUILayout.LabelField("Now editing: ", subTitleStyleA);
			EditorGUILayout.EndVertical();
			EditorGUILayout.BeginVertical();
			EditorGUILayout.LabelField(currentBoss.name, subTitleStyleB);
			EditorGUILayout.EndVertical();
			EditorGUILayout.EndHorizontal();
			EditorGUILayout.Space();

			ShowBossValues();

			EditorGUILayout.Space();
			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			if (GUILayout.Button("Save Changes", editStyle))
			{
				SaveValues();
			}
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();
		}
	}

	private void Setup()
	{
		if (newName == null)
		{
			noName = true;
			return;
		}
		else
		{
			noName = false;
		}
		CreateFolders();
		CreateObject();
	}

	private void CreateFolders()
	{
		var parent = "Assets/Art";
		if (!Directory.Exists(parent))
		{
			Directory.CreateDirectory(parent);
		}

		parent = "Assets/Art/Bosses";
		if (!Directory.Exists(parent))
		{
			Directory.CreateDirectory(parent);
		}
		var bossFolder = AssetDatabase.CreateFolder(parent, newName);
		folderPath = AssetDatabase.GUIDToAssetPath(bossFolder);
		AssetDatabase.CreateFolder(folderPath, "Animations");
		AssetDatabase.CreateFolder(folderPath, "Materials");
		AssetDatabase.CreateFolder(folderPath, "Models");
		AssetDatabase.CreateFolder(folderPath, "Prefabs");
		AssetDatabase.CreateFolder(folderPath, "Textures");
	}

	private void CreateObject()
	{
		var asset = CreateInstance<BossData>();
		AssetDatabase.CreateAsset(asset, folderPath + "/" + newName + ".asset");
		AssetDatabase.SaveAssets();
		EditorUtility.FocusProjectWindow();
		Selection.activeObject = asset;
	}

	private void SearchProject()
	{
		results.Clear();
		var allObjects = AssetDatabase.FindAssets("t:BossData");
		foreach (var thisObject in allObjects)
		{
			var temp = AssetDatabase.GUIDToAssetPath(thisObject);
			results.Add(temp);
		}
		foundBosses = true;
	}

	private void ShowObjects()
	{
		var height = Mathf.Clamp(results.Count * EditorGUIUtility.singleLineHeight, 50f, 200f);
    	resultsScroll = EditorGUILayout.BeginScrollView(resultsScroll, GUILayout.Height(100f));
    	{
    		if (results.Count < 1)
    		{
    			NoResults();
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
    	EditorGUILayout.HelpBox("No Bosses found", MessageType.Info);
    }

    private void YesResults()
    {
	    for (var i = 0; i < results.Count; i++)
	    {
		    var file = results[i];
		    EditorGUILayout.BeginHorizontal();
		    {
			    EditorGUILayout.LabelField(Path.GetFileNameWithoutExtension(file));
			    EditorGUILayout.Space();
			    if (GUILayout.Button("Edit"))
			    {
				    EditorGUIUtility.PingObject(AssetDatabase.LoadAssetAtPath(file, typeof(Object)));
				    currentBoss = (BossData) AssetDatabase.LoadAssetAtPath(file, typeof(Object));
				    initialized = false;
				    editingBoss = true;
			    }

			    if (GUILayout.Button("Delete"))
			    {
				    if (EditorUtility.DisplayDialog("Are you sure you want to delete this?", "Delete " + file, "Confirm", "Cancel"))
				    {
					    AssetDatabase.DeleteAsset(file);
					    results.Remove(file);
					    SearchProject();
				    }
			    }
		    }
		    EditorGUILayout.EndHorizontal();
	    }
    }

    private void ShowBossValues()
    {
	    if (!initialized)
	    {
		    GetValues();
	    }

	    EditorGUIUtility.labelWidth = EditorGUIUtility.currentViewWidth * 0.33f;
	    EditorGUILayout.BeginHorizontal();
	    level = EditorGUILayout.IntField("Level",level);
	    EditorGUILayout.EndHorizontal();
	    EditorGUILayout.BeginHorizontal();
	    attackPower = EditorGUILayout.FloatField("Attack Power", attackPower);
	    EditorGUILayout.EndHorizontal();
	    EditorGUILayout.BeginHorizontal();
	    attackSpeed = EditorGUILayout.FloatField("Attack Speed", attackSpeed);
	    EditorGUILayout.EndHorizontal();
	    EditorGUILayout.BeginHorizontal();
	    critChance = EditorGUILayout.Slider("Crit Chance", critChance, 0f, 100f);
	    EditorGUILayout.EndHorizontal();
	    EditorGUILayout.BeginHorizontal();
	    health = EditorGUILayout.FloatField("Health", health);
	    EditorGUILayout.EndHorizontal();
	    EditorGUILayout.BeginHorizontal();
	    defense = EditorGUILayout.FloatField("Defense", defense);
	    EditorGUILayout.EndHorizontal();
    }

    private void GetValues()
    {
	    Debug.Log("Getting values!");
	    level = currentBoss.Level;
	    attackPower = currentBoss.AttackPower;
	    attackSpeed = currentBoss.AttackSpeed;
	    critChance = currentBoss.CritChance;
	    health = currentBoss.Health;
	    defense = currentBoss.Defense;
	    initialized = true;
    }

    private void SaveValues()
    {
	    currentBoss.Level = level;
	    currentBoss.AttackPower = attackPower;
	    currentBoss.AttackSpeed = attackSpeed;
	    currentBoss.CritChance = critChance;
	    currentBoss.Health = health;
	    currentBoss.Defense = defense;

    }
}
