using System.Collections;
using UnityEngine;

public class ObjectSpawner : MonoBehaviour
{
	public GameObject SpawnedPrefab;
    public float delay = 5;
    public int trails = 7;
    public float emmisionTime = 0.33f;
    public Transform target = null;
    public Vector2 randomStartingOffset = Vector2.zero;

    private GameObject trail = null;
	private Transform mTrans;
    private Vector3 startP;

	private void OnEnable()
	{
		StartCoroutine(Spawn());
	}
	private IEnumerator Spawn()
	{
        if (delay > 0)
            yield return new WaitForSeconds(delay);
		mTrans = transform;
		int i = 0;
		while (i < trails)
		{
            startP = mTrans.localPosition + new Vector3(Random.Range(-1 * randomStartingOffset.x, randomStartingOffset.x), Random.Range(-1 * randomStartingOffset.y, randomStartingOffset.y), 0);
            trail = Instantiate(SpawnedPrefab, startP, mTrans.rotation);
            if (trail.GetComponent<CounterMagnet>() != null)
                trail.GetComponent<CounterMagnet>().target = target;
            i++;
            yield return new WaitForSeconds(emmisionTime);
		}
        Destroy(this);
	}
}