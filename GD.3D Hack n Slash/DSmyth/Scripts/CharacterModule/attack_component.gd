class_name AttackComponent
extends Area3D

@export var Damage : float = 10
@export var Knockback : float = 10

var AttackType : Constants.AttackType = Constants.AttackType.BASIC
var AttackOwner : Node

var Collider : CollisionShape3D 

func _ready():
	if !Collider:
		for node in get_children():
			if node is CollisionShape3D:
				Collider = node
				break
	Collider.disabled = true;

func Attack(attackOwner : Node, attackType : Constants.AttackType):
	AttackOwner = attackOwner
	AttackType = attackType
	# Turns on attack hitbox briefly
	Collider.disabled = false;
	create_tween().tween_property(Collider, "disabled", true, 0.2)
	# Plays Animation
	
	print(attackOwner.name + " attacked")
	


func _on_area_entered(area):
	if AttackOwner == null: return
	if !area is DamageableComponent: return
	
	var dmgComp : DamageableComponent = area
	var newAttackData = AttackData.new(AttackOwner, Damage, Knockback, AttackType)
	dmgComp.RecieveAttack(newAttackData)
