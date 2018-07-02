using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

public class InputDialog : EditorWindow
{
	public event System.Action<string> onInput = delegate { };
	string input = string.Empty;
	void OnEnable()
	{
		Vector2 mPos = Event.current.mousePosition;
		Rect r = EditorWindow.focusedWindow.position;
		r.x += mPos.x;
		r.y += mPos.y;
		r.width = 100;
		r.height = 50;
		position = r;
	}
	void OnGUI()
	{
		string name = "inputField" + this.GetInstanceID();
		GUI.SetNextControlName(name);
		input = EditorGUILayout.TextField(input);
		GUI.FocusControl(name);
		if (GUILayout.Button("OK") || (Event.current.isKey && Event.current.keyCode == KeyCode.Return))
		{
			onInput(input);
			Close();
		}
	}
}
public class EffectsMaterialGenerator : EditorWindow
{


	private string[] materialsToGenerate = new string[4]
	{
		"Mobile/Particles/Additive",
		"Mobile/Particles/Alpha Blended",
		"Mobile/Particles/Blend Add Particle",
		"Mobile/Particles/Multiply",
	};
	[SerializeField]
	private bool[] options = new bool[4]
	{
		true,
		true,
		true,
		true,
	};
	private List<Texture2D> genTextures = new List<Texture2D>();

	[MenuItem("Assets/Materials/Generate Particle Materials from Textures")]
	private static void GenerateMaterials()
	{
		var win = GetWindow<EffectsMaterialGenerator>();
		win.genTextures = Selection.objects.Where(q => q is Texture || q is Texture2D)
										   .Select(q => (Texture2D)q)
										   .ToList();
	}

	private void OnGUI()
	{
		for (int i = 0; i < materialsToGenerate.Length; i++)
		{
			options[i] = EditorGUILayout.Toggle(materialsToGenerate[i], options[i]);
		}
		if (GUILayout.Button("Generate Materials"))
			Generate();
	}
	private void Generate()
	{
		if (!EditorUtility.DisplayDialog("Generate Materials", string.Format("Generate materials for {0} textures?", genTextures.Count), "Generate", "Cancel"))
			return;
		List<Material> mats = new List<Material>();
		for (int i = 0; i < materialsToGenerate.Length; i++)
		{
			if (options[i])
				mats.Add(new Material(Shader.Find(materialsToGenerate[i])));
		}
		foreach (var t in genTextures)
		{
			string path = AssetDatabase.GetAssetPath(t);
			FileInfo fi = new FileInfo(path);
			if (Directory.Exists(fi.Directory + "/GeneratedMaterials/") == false)
			{
				AssetDatabase.CreateFolder(fi.Directory.FullName, "GeneratedMaterials");
			}
			for (int i = 0; i < mats.Count; i++)
			{
				Material c = new Material(mats[i]);
				c.mainTexture = t;
				string sname = c.shader.name;
				var split = sname.Split('/');
				AssetDatabase.CreateAsset(c, (fi.Directory + "/GeneratedMaterials/" + t.name + "_" + split[split.Length - 1] + ".mat"));
			}
		}
		AssetDatabase.Refresh();
	}

}