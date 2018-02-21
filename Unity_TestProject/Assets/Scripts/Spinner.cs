using System.Collections;
using UnityEngine;

public class Spinner : MonoBehaviour
{
	public Vector3 Spin;
	public float Duration = 1;
	public float Speed = 1;

	private Transform mTrans;
    private bool run = false;

	private void OnEnable()
	{
		mTrans = transform;
	}

    void Update()
    {
        if (Input.GetMouseButton(0) && !run)
        {
            StartCoroutine(Go());
            run = true;
        }
    }

    private IEnumerator Go()
	{
		float delta = 0;
		while (delta < Duration)
		{
			mTrans.Rotate((Spin.x * Time.deltaTime * Speed), (Spin.y * Time.deltaTime * Speed), (Spin.z * Time.deltaTime * Speed));
			delta += Time.deltaTime;
			yield return null;
		}
		yield break;
	}
}