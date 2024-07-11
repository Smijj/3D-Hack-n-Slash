class_name DamageableComponent
extends Area3D

@export var DefenceType : Constants.DefenceType = Constants.DefenceType.SOFT
@export var Crippled : bool = false

signal OnDamageTaken(attackData:AttackData)

func RecieveAttack(attackData:AttackData):
	attackData.DefenceType = DefenceType
	attackData.Crippled = Crippled
	OnDamageTaken.emit(attackData)
