using UnityEditor;
using UnityEngine;

namespace Editor
{
	[CanEditMultipleObjects]
	[CustomEditor(typeof(Transform), true)]
	public class TransformInspector : UnityEditor.Editor {
		private static TransformInspector _instance;
		private SerializedProperty mPos;
		private SerializedProperty mRot;
		private SerializedProperty mScale;

		private void OnEnable() {
			_instance = this;
			mPos = serializedObject.FindProperty("m_LocalPosition");
			mRot = serializedObject.FindProperty("m_LocalRotation");
			mScale = serializedObject.FindProperty("m_LocalScale");
		}

		private void OnDestroy() {
			_instance = null;
		}
		private static readonly GUIContent ResetButtonContent = new GUIContent("Reset", "Reset to Zero");
		private static readonly GUIContent IsolateXButtonContent = new GUIContent("X", "Set other axis to Zero");
		private static readonly GUIContent IsolateYButtonContent = new GUIContent("Y", "Set other axis to Zero");
		private static readonly GUIContent IsolateZButtonContent = new GUIContent("Z", "Set other axis to Zero");
		private static readonly GUIContent UniformXButtonContent = new GUIContent("X", "Set to uniform based on X");
		private static readonly GUIContent UniformYButtonContent = new GUIContent("Y", "Set to uniform based on Y");
		private static readonly GUIContent UniformZButtonContent = new GUIContent("Z", "Set to uniform based on X");
		private static readonly GUILayoutOption TinyButtonWidth = GUILayout.Width(17f);
		private static readonly GUILayoutOption MiniButtonWidth = GUILayout.Width(36f);
		public override void OnInspectorGUI() {
			serializedObject.Update();
			GUILayout.Label("Local Position");
			GUILayout.BeginHorizontal();
			{
				mPos.vector3Value = DrawVectorEditor(mPos.vector3Value);
				if (GUILayout.Button(ResetButtonContent, EditorStyles.miniButtonLeft, MiniButtonWidth)) {
					mPos.vector3Value = Vector3.zero;
				}
				if (GUILayout.Button(IsolateXButtonContent, EditorStyles.miniButtonMid, TinyButtonWidth)) {
					mPos.vector3Value = new Vector3(mPos.vector3Value.x, 0f, 0f);
				}
				if (GUILayout.Button(IsolateYButtonContent, EditorStyles.miniButtonMid, TinyButtonWidth)) {
					mPos.vector3Value = new Vector3(0f, mPos.vector3Value.y, 0f);
				}
				if (GUILayout.Button(IsolateZButtonContent, EditorStyles.miniButtonRight, TinyButtonWidth)) {
					mPos.vector3Value = new Vector3(0f, 0f, mPos.vector3Value.z);
				}
			}
			GUILayout.EndHorizontal();

			GUILayout.Label("Local Rotation");
			GUILayout.BeginHorizontal();
			{
				var q = mRot.quaternionValue;
				var v = q.eulerAngles;
				v = DrawVectorEditor(v);
				if (mRot.quaternionValue != Quaternion.Euler(v)) {
					mRot.quaternionValue = Quaternion.Euler(v);
				}

				if (GUILayout.Button(ResetButtonContent, EditorStyles.miniButtonLeft, MiniButtonWidth)) {
					mRot.quaternionValue = Quaternion.identity;
				}
				if (GUILayout.Button(IsolateXButtonContent, EditorStyles.miniButtonMid, TinyButtonWidth)) {
					mRot.quaternionValue = Quaternion.Euler(mScale.vector3Value.x, 0f, 0f);
				}
				if (GUILayout.Button(IsolateYButtonContent, EditorStyles.miniButtonMid, TinyButtonWidth)) {
					mRot.quaternionValue = Quaternion.Euler(0f, mScale.vector3Value.y, 0f);
				}
				if (GUILayout.Button(IsolateZButtonContent, EditorStyles.miniButtonRight, TinyButtonWidth)) {
					mRot.quaternionValue = Quaternion.Euler(0f, 0f, mScale.vector3Value.z);
				}
			}
			GUILayout.EndHorizontal();

			GUILayout.Label("Local Scale");
			GUILayout.BeginHorizontal();
			{
				mScale.vector3Value = DrawVectorEditor(mScale.vector3Value);
				if (GUILayout.Button(ResetButtonContent, EditorStyles.miniButtonLeft, MiniButtonWidth)) {
					mScale.vector3Value = Vector3.one;
				}
				if (GUILayout.Button(UniformXButtonContent, EditorStyles.miniButtonMid, TinyButtonWidth)) {
					mScale.vector3Value = new Vector3(mScale.vector3Value.x, mScale.vector3Value.x, mScale.vector3Value.x);
				}
				if (GUILayout.Button(UniformYButtonContent, EditorStyles.miniButtonMid, TinyButtonWidth)) {
					mScale.vector3Value = new Vector3(mScale.vector3Value.y, mScale.vector3Value.y, mScale.vector3Value.y);
				}
				if (GUILayout.Button(UniformZButtonContent, EditorStyles.miniButtonRight, TinyButtonWidth)) {
					mScale.vector3Value = new Vector3(mScale.vector3Value.z, mScale.vector3Value.z, mScale.vector3Value.z);
				}
			}
			GUILayout.EndHorizontal();
			serializedObject.ApplyModifiedProperties();
		}

		private static Vector3 DrawVectorEditor(Vector3 v) {
			var w = EditorGUIUtility.labelWidth;
			EditorGUIUtility.labelWidth = 12f;
			v.x = EditorGUILayout.FloatField("X", v.x, GUILayout.MinWidth(EditorGUIUtility.labelWidth));
			v.y = EditorGUILayout.FloatField("Y", v.y, GUILayout.MinWidth(EditorGUIUtility.labelWidth));
			v.z = EditorGUILayout.FloatField("Z", v.z, GUILayout.MinWidth(EditorGUIUtility.labelWidth));
			EditorGUIUtility.labelWidth = w;
			return v;
		}
	}
}