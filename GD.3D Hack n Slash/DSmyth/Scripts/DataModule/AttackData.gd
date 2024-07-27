class_name AttackData
extends Node

var AttackOwner : Node = null
var BaseDamage : float = 0
var BaseKnockback : float = 0
var AttackType : CONSTS.AttackType = CONSTS.AttackType.BASIC
var DefenceType : CONSTS.DefenceType = CONSTS.DefenceType.SOFT
var Crippled : bool = false


### Constructor: Expects- attackOwner:Node damage:float, knockback:Float, attackType:CONSTS.AttackType, defenceType:CONSTS.DefenceType
#func _init(
#attackOwner:Node,
#damage:float = 0, 
#knockback:float = 0, 
#attackType:CONSTS.AttackType = CONSTS.AttackType.BASIC, 
#defenceType:CONSTS.DefenceType = CONSTS.DefenceType.SOFT):
	#AttackOwner = attackOwner
	#AttackType = attackType
	#Damage = damage
	#Knockback = knockback
	#DefenceType = defenceType

func CalculatePostMidigationDamage(weightType:CONSTS.WeightType) -> float:
	return BaseDamage * CONSTS.CalculateDamageModifer(AttackType, weightType, DefenceType)


func Debug():
	print("ATTACKDATA:
	Attack Owner: %s
	Base Damage: %s
	Base Knockback: %s
	AttackType: %s
	DefenceType: %s" 
	% [str(AttackOwner.name), str(BaseDamage), str(BaseKnockback), CONSTS.AttackType.keys()[AttackType], CONSTS.DefenceType.keys()[DefenceType]])
