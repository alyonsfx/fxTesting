using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderTestSpawner : MonoBehaviour {

	public GameObject UI;
	public Transform Container;
	public int width = 5;
	public int height = 5;

	private void Awake() {
		ClearScene();
	}

	public void SpawnCharacter(GameObject ob) {
		for (int x = 0; x < width; x++) {
			for (int y = 0; y < height; y++) {
				Vector3 location = new Vector3(((float)x - width*0.5f) * 3, 0.7f, ((float)y - height*0.5f) * 3);
				Quaternion rotation = Quaternion.Euler(0, Random.Range(0, 360), 0f);
				Instantiate(ob, location, rotation, Container);
			}
		}
	}

	public void ClearScene() {
		foreach (Transform child in Container.transform) {
			Destroy(child.gameObject);
		}
	}
}