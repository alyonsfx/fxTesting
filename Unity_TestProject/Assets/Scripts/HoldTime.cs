using UnityEngine;
using System.Collections;

public class HoldTime : MonoBehaviour {
	public GameObject victory = null;
	public GameObject star1 = null;
	public GameObject star2 = null;
	public GameObject star3 = null;
	public GameObject text = null;
	public float duration = 5;

	private bool complete = false;
	private ParticleSystem ps = null;

	private void Awake() {
		if (!victory || !star1 || !star2 || !star3)
			Destroy(this);
		ps = text.GetComponentInChildren<ParticleSystem>();
		StartCoroutine(Delay());
	}

	private IEnumerator Delay() {
		Debug.Log("Countdown begin");
		yield return new WaitForSeconds(duration);
		Debug.Log("Countdown end");
		text.GetComponent<Renderer>().enabled = true;
		var emission = ps.emission;
		emission.enabled = true;
		star1.GetComponent<ParticleSystem>().Pause();
		star2.GetComponent<ParticleSystem>().Pause();
		star3.GetComponent<ParticleSystem>().Pause();
		victory.GetComponent<ParticleSystem>().Pause();
		complete = true;
	}

	void Update() {
		if (complete) {
			if (Input.GetMouseButton(0)) {
				//UnityEditor.EditorApplication.isPlaying = false;
			}
		}
	}
}