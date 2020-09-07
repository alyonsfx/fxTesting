using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Boss : MonoBehaviour {

	[SerializeField] private GameObject _bossObject;
	[SerializeField] private Material _overrideMaterial;
	[SerializeField] private Vector3 _overrideScale;

	private MeshRenderer bossRenderer;
	private Transform bossTransform;

	void Awake()
	{
		if (_overrideMaterial!=null)
		{
			bossRenderer = _bossObject.GetComponent<MeshRenderer>();
			bossRenderer.material = _overrideMaterial;
		}
		bossTransform = transform;
		bossTransform.localScale = _overrideScale;
	}
}
