class_name Character
extends CharacterBody3D

@export_category("Settings")
@export var MoveSpeed = 5.0
@export var JumpVelocity = 4.5
# Get the Gravity from the project settings to be synced with RigidBody nodes.
var Gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_category("References")
@export var StatsComp : StatsComponent
@export var AttackComp : AttackComponent
@export var DamageableComps : Array[DamageableComponent]


func _ready():
	if !StatsComp or DamageableComps.size() == 0: return
	for comp in DamageableComps:
		comp.OnDamageTaken.connect(StatsComp.TakeDamage)


func Die():
	queue_free()
	pass
