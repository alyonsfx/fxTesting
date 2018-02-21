using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShootBlaster : MonoBehaviour {
    private ParticleSystem ps = null;

    void Start()
    {
        ps = GetComponent<ParticleSystem>();
    }

    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            ps.Emit(1);
        }
    }
}