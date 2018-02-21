using UnityEngine;
using System.Collections;

public class StartAttackDemo : MonoBehaviour
{
    public ParticleSystem Attack = null;
    public ParticleSystem Impact = null;
    public ParticleSystem Block = null;

    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            Attack.time = 0f;
            Attack.Play();
            Impact.time = 0f;
            Impact.Play();
        }
        if (Input.GetMouseButton(1))
        {
            Attack.time = 0f;
            Attack.Play();
            Block.time = 0f;
            Block.Play();
        }
    }
}