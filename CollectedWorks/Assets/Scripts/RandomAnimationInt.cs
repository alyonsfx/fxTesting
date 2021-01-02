using UnityEngine;

public class RandomAnimationInt : StateMachineBehaviour
{
	[SerializeField] private int[] ints;
	[SerializeField] private string targetParameter;


	public override void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
	{
		animator.SetInteger(targetParameter, ints[Random.Range(0,ints.Length)]);
	}
}