using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderTestSpawner : MonoBehaviour {

	public GameObject UI;
	public Transform Container;

	private void Awake() {
		ClearScene();
	}



	public void SpawnCharacter(GameObject ob) {
		int width = 5;
		int height = 5;
		for (int x = 0; x < width; x++) {
			for (int y = 0; y < height; y++) {
				Vector3 location = new Vector3(((float)x - 2.5f) * 3, 0f, ((float)y - 2.5f) * 3);
				Quaternion rot = Quaternion.Euler(0, Random.Range(0, 360), 0f);
				Instantiate(ob, location, rot, Container);
			}
		}
	}

	public void ClearScene() {
		foreach (Transform child in Container.transform) {
			Destroy(child.gameObject);
		}
	}
}