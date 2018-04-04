using UnityEngine;

[ExecuteInEditMode]
public class CameraFacing : MonoBehaviour {
	public bool reverse = false;

	private void Update() {
		if (Camera.main != null) {
			Vector3 difference = Camera.main.transform.position - transform.position;
			if (reverse) difference *= -1;
			Quaternion rotation = Quaternion.LookRotation(difference, Vector3.up);
			transform.rotation = rotation;
		}
	}
}