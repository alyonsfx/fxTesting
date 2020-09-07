using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OverlayStepper : MonoBehaviour
{
    public float interval = 0.2f;

    private Material mat = null;
    private int s = 0;
    public Color temp = Color.white;

	void Start ()
    {
        if (!GetComponent<Renderer>())
            Destroy(this);
        mat = GetComponent<Renderer>().materials[1];
        if (mat.HasProperty("_Step"))
        {
            temp = mat.GetColor("_Color");
            mat.SetColor("_Color",new Color(temp.r,temp.g,temp.b,0f));
            Debug.Log("Alpha 0");
        }
        else
            Destroy(this);
    }

    public IEnumerator Intro(float duration)
    {
        yield return new WaitForSeconds(duration);
        mat.SetColor("_Color", temp);
        Debug.Log("Alpha Now " + temp.a);
        StartCoroutine(Set());
    }

    private IEnumerator Set()
    {
        mat.SetFloat("_Step", s);
        s = Random.Range(0, 4);
        StartCoroutine(Delay(interval));
        yield return null;
    }
    private IEnumerator Delay(float duration)
    {
        yield return new WaitForSeconds(duration);
        StartCoroutine(Set());
    }
}
