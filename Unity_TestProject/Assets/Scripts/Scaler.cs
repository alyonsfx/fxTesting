using UnityEngine;

public class Scaler : MonoBehaviour
{
    public AnimationCurve Curve;
	public float Speed = 1;
	
	private Vector3 OriginalScale;
	private Vector3 Temp;
	private float StartTime;

	private void Awake()
	{
		OriginalScale = transform.localScale;
	}

	private void OnEnable()
	{
		transform.localScale = OriginalScale;
		StartTime = Time.time;
	}

    private void OnDisable()
	{
		transform.localScale = OriginalScale;
    }

    private void Update()
	{
		float t = (Time.time - StartTime) / Speed;
		Temp = OriginalScale * Curve.Evaluate(t);
		transform.localScale = Temp;
	}
}