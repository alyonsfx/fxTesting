// Used with custom shader to move particles away from a transform

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(ParticleSystem))]
public class ParticleMagnet : MonoBehaviour
{
    [SerializeField] private GameObject _magnet = null;

    private Material _mat = null;
    private ParticleSystemRenderer _psRenderer = null;

    private void Start()
    {
        _psRenderer = GetComponent<ParticleSystemRenderer>();
        _mat = _psRenderer.material;
    }

    private void Update()
    {
        Vector4 magPos = new Vector4(_magnet.transform.position.x, _magnet.transform.position.y, _magnet.transform.position.z, 0);
        MaterialEdit.SetMaterialVector(_mat, "_Mag", magPos);
    }
}
