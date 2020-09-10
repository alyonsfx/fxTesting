using UnityEngine;

public class BossData : ScriptableObject
{
	[SerializeField] private int level;
	[SerializeField] private float attackPower;
	[SerializeField] private float attackSpeed;
	[SerializeField] private float critChance;
	[SerializeField] private float health;
	[SerializeField] private float defense;

#if UNITY_EDITOR
	public int Level { get => level; set => level = value; }
	public float AttackPower { get => attackPower; set => attackPower = value; }
	public float AttackSpeed { get => attackSpeed; set => attackSpeed = value; }
	public float CritChance { get => critChance; set => critChance = value; }
	public float Health { get => health; set => health = value; }
	public float Defense { get => defense; set => defense = value; }
#endif
}
