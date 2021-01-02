using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomTextureOffseter : MonoBehaviour
{
    public float Interval = 0.2f;
    public float Delay = 2.5f;
    private Material mat = null;
    //private int s = 0;
    private Color temp = Color.white;
    private int count = 0;

    void Start()
    {
        if (!GetComponent<Renderer>())
            Destroy(this);
        mat = GetComponent<Renderer>().materials[1];
        temp = mat.GetColor("_Color");
        mat.SetColor("_Color", new Color(temp.r, temp.g, temp.b, 0f));
        StartCoroutine(Intro(Delay));
    }

    public IEnumerator Intro(float duration)
    {
        yield return new WaitForSeconds(duration);
        mat.SetColor("_Color", temp);
        StartCoroutine(setOffset());
    }

    private IEnumerator setOffset()
    {
        mat.SetTextureOffset("_MainTex", new Vector2(Random.Range(0f,1f), Random.Range(0f, 1f)));
        StartCoroutine(delayCount(Interval));
        count++;
        yield return null;
    }
    private IEnumerator delayCount(float duration)
    {
        if (count < 25)
        {
            yield return new WaitForSeconds(duration);
            StartCoroutine(setOffset());
        }
        else
        {
            mat.SetColor("_Color", new Color(temp.r, temp.g, temp.b, 0f));
            Destroy(this);
        }

    }
}