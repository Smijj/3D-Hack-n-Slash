class_name StatsComponent
extends Node

@export var MaxHealth : float = 100
var CurrentHealth : float = 100
@export var WeightType : Constants.WeightType = Constants.WeightType.LIGHT


func TakeDamage(attackData:AttackData):
	print("RECIVE DAMAGE> AttackOwner: "+ attackData.AttackOwner.name + ", StatsOwner: "+owner.name)
	# Checks to make sure this StatsComp isnt part of the same Character - to not hurt thineself
	if attackData.AttackOwner == owner: return
	
	AttackData.DebugAttackData(attackData)
	pass


