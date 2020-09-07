using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EmitNow : MonoBehaviour {
    private ParticleSystem ps = null;

    void Start()
    {
        ps = GetComponent<ParticleSystem>();
    }

    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            ps.Play();
        }
    }
}