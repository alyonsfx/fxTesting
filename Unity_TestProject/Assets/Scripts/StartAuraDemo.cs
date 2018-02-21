using UnityEngine;
using System.Collections;

public class StartAuraDemo : MonoBehaviour
{
    public ParticleSystem Stream = null;
    public ParticleSystem Burst = null;
    public OverlayStepper PlayerGeo = null;

    void Update()
    {
        if (Input.GetMouseButton(0) || Input.GetMouseButton(1))
        {
            Stream.time = 0f;
            Stream.Play();
            Burst.time = 0f;
            Burst.Play();
            PlayerGeo.StartCoroutine(PlayerGeo.Intro(0f));
            Destroy(this);
        }
    }
}