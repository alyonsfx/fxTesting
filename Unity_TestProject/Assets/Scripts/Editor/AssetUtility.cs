using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

public static class AssetUtility
{
	public static string GetFullPathToAsset(Object t)
	{
		return Path.Combine(System.Environment.CurrentDirectory, AssetDatabase.GetAssetPath(t));
	}
	/// <summary>
	/// Gets all Components of type C in the project.
	/// </summary>
	/// <remarks>This function is incredibly slow and should be used in the Editor with caution.</remarks>
	public static IEnumerable<string> GetAllAssetPathsOfType<T>() where T : Object
	{
		var typename = typeof(T).Name;
		return AssetDatabase.FindAssets("t:" + typename).Select(g => AssetDatabase.GUIDToAssetPath(g));
	}
	/// <summary>
	/// Gets all Components of type C in the project.
	/// </summary>
	/// <remarks>This function is incredibly slow and should be used in the Editor with caution.</remarks>
	public static IEnumerable<T> GetAllAssetsOfType<T>() where T : Object
	{
		return GetAllAssetPathsOfType<T>().Select(p => AssetDatabase.LoadAssetAtPath<T>(p));
	}
	/// <summary>
	/// Gets all Components of type C in the project.
	/// </summary>
	/// <remarks>This function is incredibly slow and should be used in the Editor with caution.</remarks>
	public static IEnumerable<C> GetAllGameObjectsWithComponent<C>() where C : Component
	{
		return AssetDatabase.FindAssets("t:Prefab").Select(g => AssetDatabase.GUIDToAssetPath(g))
												   .SelectMany(p => GetAllWithComponentAtPath<C>(p));
	}
	/// <summary>
	/// Gets all Components of exact type C in the project.
	/// </summary>
	/// <remarks>This function is incredibly slow and should be used in the Editor with caution.</remarks>
	public static IEnumerable<C> GetAllGameObjectsWithExactComponent<C>() where C : Component
	{
		return GetAllGameObjectsWithComponent<C>().Where(cs => cs.GetType() == typeof(C));
	}
	/// <summary>
	/// Gets all Components of type C in the project.
	/// </summary>
	/// <remarks>This function is incredibly slow and should be used in the Editor with caution.</remarks>
	public static IEnumerable<C> GetAllWithComponentAtPath<C>(string assetPath) where C : Component
	{
		return AssetDatabase.LoadAssetAtPath<GameObject>(assetPath).GetComponentsInChildren<C>(true).Where(cs => cs != null);
	}
	public static void AddLabel(string assetPath, string label)
	{
		var asset = AssetDatabase.LoadAssetAtPath<Object>(assetPath);
		var labels = AssetDatabase.GetLabels(asset);
		for (int i = 0; i < labels.Length; i++)
		{
			if (labels[i] == label)
			{
				return;
			}
		}
		ArrayUtility.Add(ref labels, label);
		AssetDatabase.SetLabels(asset, labels);
	}
}