using UnityEngine;

[RequireComponent(typeof(ParticleSystem))]
public class EmitNow : MonoBehaviour {
    [SerializeField] private ParticleSystem _targetSystem = null;

    void Start()
    {
		if (_targetSystem == null)
		{
            _targetSystem = GetComponent<ParticleSystem>();
		}
    }

    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            _targetSystem.Play();
        }
    }
}