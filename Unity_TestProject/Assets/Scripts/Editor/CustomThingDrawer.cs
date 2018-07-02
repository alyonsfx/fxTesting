using UnityEngine;
using UnityEditor;

[CustomPropertyDrawer(typeof(CustomThing))]
public class CustomThingDrawer : PropertyDrawer
{
    public override void OnGUI(Rect pos, SerializedProperty prop, GUIContent label)
    {
        int oldIndentLevel = EditorGUI.indentLevel;
        label = EditorGUI.BeginProperty(pos, label, prop);
        Rect contentPos = EditorGUI.PrefixLabel(pos, label);
        if (pos.height > 16f)
        {
            pos.height = 16f;
            EditorGUI.indentLevel += 1;
            contentPos = EditorGUI.IndentedRect(pos);
            contentPos.y += 18f;
        }
        contentPos.width *= 0.75f;
        EditorGUI.indentLevel = 0;
        EditorGUI.PropertyField(contentPos, prop.FindPropertyRelative("MyLocation"), GUIContent.none);
        contentPos.x += contentPos.width;
        contentPos.width /= 3f;
        EditorGUIUtility.labelWidth = 14f;
        EditorGUI.PropertyField(contentPos, prop.FindPropertyRelative("MyColor"), new GUIContent("C"));
        EditorGUI.EndProperty();
        EditorGUI.indentLevel = oldIndentLevel;
    }
    public override float GetPropertyHeight(SerializedProperty prop, GUIContent label)
    {
        return label != GUIContent.none && Screen.width < 333 ? (16f + 18f) : 16f;
    }
}