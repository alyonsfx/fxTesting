using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticleMagnet : MonoBehaviour {
	public GameObject Magnet = null;
	private Material _mat = null;
	private ParticleSystemRenderer r = null;

	private void Start () {
		r = GetComponent <ParticleSystemRenderer> ();
		_mat = r.material;
	}

	private void Update () {
		Vector4 magPos = new Vector4 (Magnet.transform.position.x, Magnet.transform.position.y, Magnet.transform.position.z, 0);
		_mat.SetVector ("_Mag", magPos);
	}
}
