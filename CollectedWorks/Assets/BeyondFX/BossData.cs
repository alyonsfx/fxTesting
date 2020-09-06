using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BossData : ScriptableObject
{
	public enum affinity
	{
		Earth,
		Fire,
		Water,
		Wind,
	}

	public struct heroBase
	{
		public string Name;
		public affinity DamageType;
		public float Health;
		public float Defense;
	}

	[SerializeField] private Boss _bossPrefab;
	[SerializeField] private string _name;
	[SerializeField] private int _level;
	[SerializeField] private float _levelMultiplier;
	[SerializeField] private affinity _damageType;
	[SerializeField] private float _health;
	[SerializeField] private float _defense;
	[SerializeField] private float _attackPower;
	[SerializeField] private float _attackSpeed;
	[SerializeField] private int _critChance;
	[SerializeField] private float _moveSpeed;

	private Boss boss;

	public void OnSpawnBossHandler()
	{
		boss = Instantiate(_bossPrefab.gameObject).GetComponent<Boss>();
	}

	public void OnAttackHandler(heroBase hero)
	{
		var damageOutput = _attackPower;
		damageOutput *= 1 + _level * _levelMultiplier;
		damageOutput = Random.Range(0,100) <= _critChance ? damageOutput * 2f : damageOutput;
		Debug.Log("{_name} did {damageOutput} to {hero.Name}");
	}

}
