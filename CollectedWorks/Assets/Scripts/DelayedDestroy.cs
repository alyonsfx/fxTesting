using System.Collections;
using UnityEngine;

public class DelayedDestroy : MonoBehaviour
{
	public float Delay = 0;
	private void OnEnable()
	{
		StartCoroutine(Wait());
	}
	private IEnumerator Wait()
	{
        yield return new WaitForSeconds(Delay);
		Destroy(gameObject);
	}
}