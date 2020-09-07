using UnityEditor;

namespace PersonalEditorTools.Editor
{
	public class PrefabEnvironment
	{
		[MenuItem("Assets/Set Prefab Environment")]
		private static void ChangeEnvironment()
		{
			var temp = (SceneAsset) Selection.activeObject;
			EditorSettings.prefabRegularEnvironment = temp;
		}

		[MenuItem("Assets/Set Prefab Environment", true)]
		private static bool ChangeEnvironmentCheck()
		{
			return Selection.activeObject is SceneAsset;
		}

		[MenuItem("Assets/Reset Prefab Environment")]
		private static void ResetEnvironment()
		{
			EditorSettings.prefabRegularEnvironment = AssetDatabase.LoadAssetAtPath<SceneAsset>("Assets/Mino/Scenes/PrefabEnvironments/RegularEnvironment.unity");
		}
	}
}