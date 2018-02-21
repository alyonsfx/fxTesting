using UnityEngine;
using System.Collections;

public class StartMenuDemo : MonoBehaviour
{
    private GameObject overlay, text;

    private bool complete = false;
    private Renderer r = null;
    private ParticleSystem ps = null;

    public GameObject Overlay
    {
        get
        {
            return overlay;
        }

        set
        {
            overlay = value;
        }
    }

    private void Awake()
    {
        if(!Overlay || !text)
            Destroy(this);
        //Time.timeScale = 0f;
        r = text.GetComponent<Renderer>();
        ps = text.GetComponentInChildren<ParticleSystem>();
    }
    void Update()
    {
        if (!complete)
        {
            if (Input.GetMouseButton(0))
            {
                r.enabled = false;
                if (!ps)
                    Debug.Log("No PS");
                var emission = ps.emission;
                emission.enabled = false;
                Overlay.SetActive(true);
                //overlay.SetActiveRecursively(true);
                complete = true;
            }
        }
        else
            Destroy(this);
    }
}