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
	private static GUIContent _resetButtonContent = new GUIContent("Reset", "Reset to Zero");
	private static GUIContent _isolateXButtonContent = new GUIContent("X", "Set other axis to Zero");
	private static GUIContent _isolateYButtonContent = new GUIContent("Y", "Set other axis to Zero");
	private static GUIContent _isolateZButtonContent = new GUIContent("Z", "Set other axis to Zero");
	private static GUIContent _uniformXButtonContent = new GUIContent("X", "Set to uniform based on X");
	private static GUIContent _uniformYButtonContent = new GUIContent("Y", "Set to uniform based on Y");
	private static GUIContent _uniformZButtonContent = new GUIContent("Z", "Set to uniform based on X");
	private static GUILayoutOption _tinyBottonWidth = GUILayout.Width(17f);
	private static GUILayoutOption _miniButtonWidth = GUILayout.Width(36f);
	public override void OnInspectorGUI() {
		serializedObject.Update();
		GUILayout.Label("Local Position");
		GUILayout.BeginHorizontal();
		{
			_mPos.vector3Value = DrawVectorEditor(_mPos.vector3Value);
			if (GUILayout.Button(_resetButtonContent, EditorStyles.miniButtonLeft, _miniButtonWidth)) {
				_mPos.vector3Value = Vector3.zero;
			}
			if (GUILayout.Button(_isolateXButtonContent, EditorStyles.miniButtonMid, _tinyBottonWidth)) {
				_mPos.vector3Value = new Vector3(_mPos.vector3Value.x, 0f, 0f);
			}
			if (GUILayout.Button(_isolateYButtonContent, EditorStyles.miniButtonMid, _tinyBottonWidth)) {
				_mPos.vector3Value = new Vector3(0f, _mPos.vector3Value.y, 0f);
			}
			if (GUILayout.Button(_isolateZButtonContent, EditorStyles.miniButtonRight, _tinyBottonWidth)) {
				_mPos.vector3Value = new Vector3(0f, 0f, _mPos.vector3Value.z);
			}
		}
		GUILayout.EndHorizontal();

		GUILayout.Label("Local Rotation");
		GUILayout.BeginHorizontal();
		{
			Quaternion q = _mRot.quaternionValue;
			Vector3 v = q.eulerAngles;
			v = DrawVectorEditor(v);
			if (_mRot.quaternionValue != Quaternion.Euler(v)) {
				_mRot.quaternionValue = Quaternion.Euler(v);
			}

			if (GUILayout.Button(_resetButtonContent, EditorStyles.miniButtonLeft, _miniButtonWidth)) {
				_mRot.quaternionValue = Quaternion.identity;
			}
			if (GUILayout.Button(_isolateXButtonContent, EditorStyles.miniButtonMid, _tinyBottonWidth)) {
				_mRot.quaternionValue = Quaternion.Euler(_mScale.vector3Value.x, 0f, 0f);
			}
			if (GUILayout.Button(_isolateYButtonContent, EditorStyles.miniButtonMid, _tinyBottonWidth)) {
				_mRot.quaternionValue = Quaternion.Euler(0f, _mScale.vector3Value.y, 0f);
			}
			if (GUILayout.Button(_isolateZButtonContent, EditorStyles.miniButtonRight, _tinyBottonWidth)) {
				_mRot.quaternionValue = Quaternion.Euler(0f, 0f, _mScale.vector3Value.z);
			}
		}
		GUILayout.EndHorizontal();

		GUILayout.Label("Local Scale");
		GUILayout.BeginHorizontal();
		{
			_mScale.vector3Value = DrawVectorEditor(_mScale.vector3Value);
			if (GUILayout.Button(_resetButtonContent, EditorStyles.miniButtonLeft, _miniButtonWidth)) {
				_mScale.vector3Value = Vector3.one;
			}
			if (GUILayout.Button(_uniformXButtonContent, EditorStyles.miniButtonMid, _tinyBottonWidth)) {
				_mScale.vector3Value = new Vector3(_mScale.vector3Value.x, _mScale.vector3Value.x, _mScale.vector3Value.x);
			}
			if (GUILayout.Button(_uniformYButtonContent, EditorStyles.miniButtonMid, _tinyBottonWidth)) {
				_mScale.vector3Value = new Vector3(_mScale.vector3Value.y, _mScale.vector3Value.y, _mScale.vector3Value.y);
			}
			if (GUILayout.Button(_uniformZButtonContent, EditorStyles.miniButtonRight, _tinyBottonWidth)) {
				_mScale.vector3Value = new Vector3(_mScale.vector3Value.z, _mScale.vector3Value.z, _mScale.vector3Value.z);
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