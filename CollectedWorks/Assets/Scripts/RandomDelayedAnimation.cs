using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomDelayedAnimation : StateMachineBehaviour
{
	[SerializeField] private string[] possibleStates;
	[SerializeField] private Vector2 minMaxDelay;

	private string nextAnim;
	private float nextAnimTime;

	public override void OnStateUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
	{
		// wait for the delay to play the next animation
		if (Time.time > nextAnimTime && !string.IsNullOrEmpty(nextAnim))
		{
			animator.Play(nextAnim);
			nextAnim = string.Empty;
		}
	}

	public override void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
	{
		// choose a new animation
		nextAnim = possibleStates[UnityEngine.Random.Range(0, possibleStates.Length)];
		nextAnimTime = Time.time + UnityEngine.Random.Range(minMaxDelay.x, minMaxDelay.y);
	}
}