class_name AttackComponent
extends Area3D

@export var Damage : float = 10
@export var Knockback : float = 10

# Data
var AttackType : Constants.AttackType = Constants.AttackType.BASIC
var AttackOwner : Node

# Refs
@export var Collider : CollisionShape3D 

var _ResetAttackTween : Tween

#region Core Functions & Events 

func _ready():
	if !Collider:
		for node in get_children():
			if node is CollisionShape3D:
				Collider = node
				break
	Collider.disabled = true;

func _on_area_entered(area):
	if AttackOwner == null: return
	if !area is DamageableComponent: return
	
	var dmgComp : DamageableComponent = area
	var newAttackData = AttackData.new(AttackOwner, Damage, Knockback, AttackType)
	dmgComp.RecieveAttack(newAttackData)

#endregion


func Attack(attackOwner : Node, attackType : Constants.AttackType):
	AttackOwner = attackOwner
	AttackType = attackType
	
	# Turns on attack hitbox briefly
	Collider.disabled = false;
	
	if _ResetAttackTween: _ResetAttackTween.kill()
	_ResetAttackTween = create_tween()
	_ResetAttackTween.tween_callback(_ResetAttack).set_delay(0.2)
	
	# Plays Animation
	
	print(attackOwner.name + " attacked")

func _ResetAttack():
	if !Collider: return
	Collider.disabled = true;

