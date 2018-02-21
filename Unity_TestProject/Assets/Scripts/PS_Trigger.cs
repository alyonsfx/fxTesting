using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PS_Trigger : MonoBehaviour
{
    public GameObject ImpactFX = null;

    private ParticleSystem ps = null;
    private bool firstContact = false;
    private Vector3 ImpactPosition = Vector3.zero;
    private Component c = null;

    void OnParticleTrigger()
    {
        if (!firstContact)
        {
            ps = GetComponent<ParticleSystem>();
            c = ps.trigger.GetCollider(0);
            ImpactPosition = c.transform.position;
            List<ParticleSystem.Particle> enter = new List<ParticleSystem.Particle>();
            int numEnter = ps.GetTriggerParticles(ParticleSystemTriggerEventType.Enter, enter);
            if (numEnter > 0)
            {
                Instantiate(ImpactFX, ImpactPosition, Quaternion.Euler(Vector3.zero));
                c.gameObject.GetComponentInChildren<LineRenderer>().enabled = false;
                firstContact = true;
            }
        }
    }
}
