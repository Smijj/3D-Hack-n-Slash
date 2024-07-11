class_name AttackComponent
extends Node

@export var Damage : float = 10
@export var Knockback : float = 10
@export var AttackType : Constants.AttackType = Constants.AttackType.BASIC

func Attack(attackType:Constants.AttackType):
	# Sets attackType
	# Turns on attack hitbox briefly
	# Plays Animation
	pass


func _on_area_entered(area):
	if area is DamageableComponent:
		# Need a check to make sure this DmgComp isnt part of the same Character - to not hurt thineself
		var dmgComp : DamageableComponent = area
		var newAttackData = AttackData.new(Damage, Knockback, AttackType)
		dmgComp.RecieveAttack(newAttackData)
