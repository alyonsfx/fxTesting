//----------------------------------------------
//			  NGUI: Next-Gen UI kit
// Copyright © 2011-2014 Tasharen Entertainment
//----------------------------------------------

using UnityEditor;
using UnityEngine;

[CanEditMultipleObjects]
[CustomEditor(typeof(Transform), true)]
public class TransformInspector : Editor {
	static public TransformInspector Instance;

	private SerializedProperty _mPos;
	private SerializedProperty _mRot;
	private SerializedProperty _mScale;

	private void OnEnable() {
		Instance = this;

		_mPos = serializedObject.FindProperty("m_LocalPosition");
		_mRot = serializedObject.FindProperty("m_LocalRotation");
		_mScale = serializedObject.FindProperty("m_LocalScale");
	}

	private void OnDestroy() {
		Instance = null;
	}

	public override void OnInspectorGUI() {
		serializedObject.Update();
		GUILayout.Label("Local Position");
		GUILayout.BeginHorizontal();
		{
			_mPos.vector3Value = DrawVectorEditor(_mPos.vector3Value);
			if(GUILayout.Button("Reset", GUILayout.Width(50))) {
				_mPos.vector3Value = Vector3.zero;
			}
		}
		GUILayout.EndHorizontal();
		GUILayout.Label("Local Rotation");
		GUILayout.BeginHorizontal();
		{
			Quaternion q = _mRot.quaternionValue;
			Vector3 v = q.eulerAngles;
			v = DrawVectorEditor(v);
			if(_mRot.quaternionValue != Quaternion.Euler(v)) {
				_mRot.quaternionValue = Quaternion.Euler(v);
			}

			if(GUILayout.Button("Reset", GUILayout.Width(50))) {
				_mRot.quaternionValue = Quaternion.identity;
			}
		}
		GUILayout.EndHorizontal();
		GUILayout.Label("Local Scale");
		GUILayout.BeginHorizontal();
		{
			_mScale.vector3Value = DrawVectorEditor(_mScale.vector3Value);
			if(GUILayout.Button("Reset", GUILayout.Width(50))) {
				_mScale.vector3Value = Vector3.one;
			}
		}
		GUILayout.EndHorizontal();
		serializedObject.ApplyModifiedProperties();
	}

	private static Vector3 DrawVectorEditor(Vector3 v) {
		float w = EditorGUIUtility.labelWidth;
		EditorGUIUtility.labelWidth = 12f;
		v.x = EditorGUILayout.FloatField("X", v.x, GUILayout.MinWidth(EditorGUIUtility.labelWidth));
		v.y = EditorGUILayout.FloatField("Y", v.y, GUILayout.MinWidth(EditorGUIUtility.labelWidth));
		v.z = EditorGUILayout.FloatField("Z", v.z, GUILayout.MinWidth(EditorGUIUtility.labelWidth));
		EditorGUIUtility.labelWidth = w;
		return v;
	}
}