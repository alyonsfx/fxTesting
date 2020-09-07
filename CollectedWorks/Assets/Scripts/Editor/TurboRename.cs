using System;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;

public enum NumberedMethod
{
    BySelection = 0,
    ByHierarchy = 1
}

[Serializable]
public class TurboRename : EditorWindow
{
	private Object[] selectedObjects = new Object[0];
	private GameObject[] selectedGameObjectObjects = new GameObject[0];
	private string[] previewSelectedObjects = new string[0];
	private bool useBaseName;
	private string baseName;
	private bool usePrefix;
	private string prefix;
	private bool useSuffix;
	private string suffix;

	private bool useInsert;
	private string insert;
	private bool insertRight;
	private int insertPos;

    public NumberedMethod numberMethod;
    private bool useNumbered;
    private int baseNumbered;
    private int stepNumbered = 1;
    private bool useReplace;
    private string replace;
    private string replaceWith;
    private bool useRemove;
    private string remove;

    private bool showSelection;
    // Add menu item named "My Window" to the Window menu
    [MenuItem("Tools/Turbo Rename")]
    public static void ShowWindow()
    {
        //Show existing window instance. If one doesn't exist, make one.
        var window = GetWindow(typeof(TurboRename));
        window.minSize = new Vector2(512, 128);
    }

    #region GUI

    private void OnGUI()
    {

        EditorGUILayout.BeginVertical("Box");
        GUILayout.Label("Turbo Rename", EditorStyles.boldLabel);
        EditorGUILayout.Space();

        EditorGUILayout.BeginHorizontal();
        useBaseName = EditorGUILayout.Toggle(useBaseName, GUILayout.MaxWidth(16));
        baseName = EditorGUILayout.TextField("Base Name: ", baseName);
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.Space();

        EditorGUILayout.BeginHorizontal();
        usePrefix = EditorGUILayout.Toggle(usePrefix, GUILayout.MaxWidth(16));
        prefix = EditorGUILayout.TextField("Prefix: ", prefix);
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.Space();

        EditorGUILayout.BeginHorizontal();
        useSuffix = EditorGUILayout.Toggle(useSuffix, GUILayout.MaxWidth(16));
        suffix = EditorGUILayout.TextField("Suffix: ", suffix);
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.Space();

        EditorGUILayout.BeginHorizontal();
        useInsert = EditorGUILayout.Toggle(useInsert, GUILayout.MaxWidth(16));
        EditorGUILayout.PrefixLabel("Insert: ");
        EditorGUILayout.BeginVertical();
        insert = EditorGUILayout.TextField("", insert);
        insertPos = EditorGUILayout.IntField("Position: ", insertPos);
        insertRight = EditorGUILayout.Toggle("From Right: ", insertRight);
        EditorGUILayout.EndVertical();
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.Space();

        EditorGUILayout.BeginHorizontal();
        useNumbered = EditorGUILayout.Toggle(useNumbered, GUILayout.MaxWidth(16));
        EditorGUILayout.PrefixLabel("Numbered: ");
        EditorGUILayout.BeginVertical();
        baseNumbered = EditorGUILayout.IntField("Start number: ",baseNumbered);
        stepNumbered = EditorGUILayout.IntField("Step: ",stepNumbered);
        numberMethod = (NumberedMethod)EditorGUILayout.EnumPopup(new GUIContent("Number method", "Number by position in selection, or number by hierarchy position. Note: Project files cannot be renamed with the hierarchy method as they are not present in the scene."), numberMethod);
        EditorGUILayout.EndVertical();
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.Space();

        EditorGUILayout.BeginHorizontal();
        useReplace = EditorGUILayout.Toggle(useReplace, GUILayout.MaxWidth(16));
        EditorGUILayout.PrefixLabel("Replace contents: ");
        EditorGUILayout.BeginVertical();
        replace = EditorGUILayout.TextField("Replace: ", replace);
        replaceWith = EditorGUILayout.TextField("With: ", replaceWith);
        EditorGUILayout.EndVertical();
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.Space();

        EditorGUILayout.BeginHorizontal();
        useRemove = EditorGUILayout.Toggle(useRemove, GUILayout.MaxWidth(16));
        remove = EditorGUILayout.TextField("Remove all: ", remove);
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space();

        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button(new GUIContent("Clear settings", "Renames selected objects with current settings.")))
        {
	        ClearSettings();
        }
        //Rename
        if (GUILayout.Button(new GUIContent("Rename", "Renames selected objects with current settings."))) { Rename();  }
        EditorGUILayout.EndHorizontal();


        if (selectedObjects.Length > 0)
        {
            showSelection = EditorGUILayout.Foldout(showSelection, "Selected objects and preview");
            if (showSelection)
            {
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.BeginVertical("Box");
                GUILayout.Label("Selection", EditorStyles.boldLabel);
                EditorGUILayout.Space();
                foreach (var t in selectedObjects)
                {
	                EditorGUILayout.LabelField(t.name);
                }
                EditorGUILayout.EndVertical();
                EditorGUILayout.BeginVertical("Box");
                GUILayout.Label("Preview", EditorStyles.boldLabel);
                EditorGUILayout.Space();
                for (var i = 0; i < selectedObjects.Length; i++)
                {
                    EditorGUILayout.LabelField(previewSelectedObjects[i]);
                }

                EditorGUILayout.EndVertical();
                EditorGUILayout.EndHorizontal();
            }
        }
    }

    private Vector2 scrollPos;
    #endregion

    #region Functions
    private void Update()
    {
        selectedObjects = Selection.objects;
        
        selectedGameObjectObjects = Selection.gameObjects;

        previewSelectedObjects = new string[selectedObjects.Length];

        for (var i = 0; i < selectedObjects.Length; i++)
        {
            var str = selectedObjects[i].name;
            if (useBaseName) { str = baseName; }
            if (usePrefix) { str = prefix + str; }
            if (useSuffix) { str = str + suffix; }

            if (useInsert && str.Length > insertPos+1)
            {
	            str = str.Insert(insertRight ? str.Length - insertPos : insertPos, insert);
            }

            if (useNumbered && numberMethod == NumberedMethod.BySelection) { str = str + ((baseNumbered + (stepNumbered * i))); }

            if (useRemove && remove != "") { str = str.Replace(remove, ""); }
            if (useReplace && replace != "") { str = str.Replace(replace, replaceWith); }

            if (useNumbered && numberMethod == NumberedMethod.ByHierarchy)
            {
                for (var z = 0; z < selectedGameObjectObjects.Length; z++)
                {
                    if (selectedGameObjectObjects[z] == selectedObjects[i])
                    {
                        str = str + ((baseNumbered + (stepNumbered * selectedGameObjectObjects[z].transform.GetSiblingIndex())));
                    }
                }
            }

	        previewSelectedObjects[i] = str;
        }

    }

    private void Rename()
    {

        for (var i = 0; i < selectedObjects.Length; i++)
        {
            Undo.RecordObject(selectedObjects[i], "Rename");
            if (useBaseName) { selectedObjects[i].name = baseName; }
            if (usePrefix) { selectedObjects[i].name = prefix + selectedObjects[i].name; }
            if (useSuffix) { selectedObjects[i].name = selectedObjects[i].name + suffix; }

            if (useInsert)
            {
	            var temp = selectedObjects[i].name;
	            selectedObjects[i].name = temp.Insert(insertRight ? temp.Length - insertPos : insertPos, insert);
            }

            if (useNumbered && numberMethod == NumberedMethod.BySelection) { selectedObjects[i].name = selectedObjects[i].name + ((baseNumbered + (stepNumbered * i))); }
            
            if (useRemove && remove != "") { selectedObjects[i].name = selectedObjects[i].name.Replace(remove, ""); }
            if (useReplace && replace != "") { selectedObjects[i].name = selectedObjects[i].name.Replace(replace, replaceWith); }

            if(AssetDatabase.GetAssetPath(selectedObjects[i]) != null)
            {
                AssetDatabase.RenameAsset(AssetDatabase.GetAssetPath(selectedObjects[i]), selectedObjects[i].name);
            }

        }

        for (var i = 0; i < selectedGameObjectObjects.Length; i++)
        {
            if (useNumbered && numberMethod == NumberedMethod.ByHierarchy) { selectedGameObjectObjects[i].name = selectedGameObjectObjects[i].name + ((baseNumbered + (stepNumbered * selectedGameObjectObjects[i].transform.GetSiblingIndex()))); }

        }
    }

    private void ClearSettings()
    {
	    useBaseName = false;
	    baseName = "";
	    usePrefix = false;
	    prefix = "";
	    useSuffix = false;
	    suffix = "";
	    useNumbered = false;
	    baseNumbered = 0;
	    stepNumbered = 1;

	    useInsert = false;
	    insert = "";
	    insertRight = false;
	    insertPos = 0;

	    useReplace = false;
	    replace = "";
	    replaceWith = "";

	    useRemove = false;
	    remove = "";
}
    #endregion
    

}