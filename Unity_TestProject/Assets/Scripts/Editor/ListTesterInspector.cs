using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(ListTester))]
public class ListTesterInspector : Editor
{
    public override void OnInspectorGUI()
    {
        serializedObject.Update();
        EditorList.Show(serializedObject.FindProperty("Numbers"), EditorListOption.All);
        EditorList.Show(serializedObject.FindProperty("Vectors"));
        EditorList.Show(serializedObject.FindProperty("MyThings"));
        EditorList.Show(serializedObject.FindProperty("Objects"), EditorListOption.Buttons);
        EditorList.Show(serializedObject.FindProperty("notAList"));
        serializedObject.ApplyModifiedProperties();
    }
}