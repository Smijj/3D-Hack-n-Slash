class_name StatsComponent
extends Node

@export var MaxHealth : float = 100
var CurrentHealth : float = 100
@export var WeightType : Constants.WeightType = Constants.WeightType.LIGHT


func TakeDamage(attackData:AttackData):
	
	AttackData.DebugAttackData(attackData)
	pass


