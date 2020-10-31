using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationTriggers : MonoBehaviour
{
    [SerializeField] private List<ParticleSystem> ParticleSystems = new List<ParticleSystem>();

    public void TriggerParticles(int index)
    {
        ParticleSystems[index].Play();
    }
}
