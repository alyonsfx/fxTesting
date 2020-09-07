using System.Linq;
using N3twork;
using UnityEngine;
using UnityEditor;

public class LayerOrderOffset : EditorWindow
{
	private GameObject[] selectedGameObjs = new GameObject[0];
	private int offset;
	private string objectName;
	private int oldLayer;

	[MenuItem("Tools/Layer Order Offset")]
	public static void ShowWindow()
	{
		var window = GetWindow(typeof(LayerOrderOffset), true);
		window.minSize = new Vector2(160, 50);
	}

	private void OnGUI()
	{
		EditorGUILayout.BeginHorizontal();
		offset = EditorGUILayout.IntField("Offset Amount", offset);
		EditorGUILayout.EndHorizontal();

		EditorGUILayout.BeginHorizontal();
		if (GUILayout.Button("Apply Offset") && Selection.gameObjects.Length>0)
		{
			ApplyOffset();
		}
		EditorGUILayout.EndHorizontal();
	}

	private void ApplyOffset()
	{
		selectedGameObjs = Selection.gameObjects;
		var count = selectedGameObjs.Count();
		for (var i = 0; i < count; i++)
		{
			objectName = selectedGameObjs[i].name;
			var sprite = selectedGameObjs[i].GetComponent<SpriteRenderer>();
			if (sprite != null)
			{
				oldLayer = sprite.sortingOrder;
				sprite.sortingOrder += offset;
			}
			else
			{
				var rend = selectedGameObjs[i].GetComponent<ParticleSystemRenderer>();
				if (rend != null)
				{
					oldLayer = rend.sortingOrder;
					rend.sortingOrder += offset;
				}
			}

			Debug.Log(objectName + " was layer order " + oldLayer + " and is now layer order" + (oldLayer+offset));
			Close();
		}
	}
}
