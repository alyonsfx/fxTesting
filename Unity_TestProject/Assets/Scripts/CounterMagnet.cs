using System.Collections;
using UnityEngine;

public class CounterMagnet : MonoBehaviour
{
    public Transform target = null;
    public float travelTime = 0.7f;
    public AnimationCurve curve = new AnimationCurve() { keys = new Keyframe[2] { new Keyframe(0, 0), new Keyframe(1, 1) } };
    public float delayedDestory = 1f;
    public GameObject impactFX = null;

    private float t = 0;
    private Vector3 startPos = Vector3.zero;
    private Vector3 endPos = Vector3.one;
    private Transform mTrans = null;

    private void OnEnable()
    {
        mTrans = transform;
        startPos = mTrans.position;
        StartCoroutine(go());
    }

    private IEnumerator go()
    {
        yield return new WaitForSeconds(0.02f);
        endPos = target.position;
        while (t < travelTime)
        {
            float tween = t / travelTime;
            tween = curve.Evaluate(tween);
            Vector3 temp = Vector3.Lerp(startPos, endPos, tween);
            mTrans.position = temp;
            t += Time.deltaTime;
            yield return null;
        }
        Instantiate(impactFX, endPos+Vector3.forward*0.1f, target.rotation);
        yield return new WaitForSeconds(delayedDestory);
        Destroy(gameObject);
    }

}