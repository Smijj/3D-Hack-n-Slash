class_name AttackData
extends Node

var AttackOwner : Node
var Damage : float
var Knockback : float
var AttackType : Constants.AttackType
var DefenceType : Constants.DefenceType = Constants.DefenceType.SOFT
var Crippled : bool = false


# Constructor: Expects- attackOwner:Node damage:float, knockback:Float, attackType:Constants.AttackType, defenceType:Constants.DefenceType
func _init(
attackOwner:Node,
damage:float = 0, 
knockback:float = 0, 
attackType:Constants.AttackType = Constants.AttackType.BASIC, 
defenceType:Constants.DefenceType = Constants.DefenceType.SOFT):
	AttackOwner = attackOwner
	AttackType = attackType
	Damage = damage
	Knockback = knockback
	DefenceType = defenceType



static func DebugAttackData(attackData:AttackData):
	print("\nATTACKDATA:
	AttackOwner: %s
	Damage: %s
	Knockback: %s
	AttackType: %s
	DefenceType: %s" 
	% [str(attackData.AttackOwner), str(attackData.Damage), str(attackData.Knockback), str(attackData.AttackType), str(attackData.DefenceType)])
