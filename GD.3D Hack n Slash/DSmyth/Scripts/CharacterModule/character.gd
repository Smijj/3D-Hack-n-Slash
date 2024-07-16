class_name Character
extends CharacterBody3D

@export_category("Character Settings")
@export var MoveSpeed = 5.0
@export var JumpVelocity = 4.5
# Get the Gravity from the project settings to be synced with RigidBody nodes.
var Gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_category("Character Stats")
@export var MaxHealth : float = 100
@export var WeightType : Constants.WeightType = Constants.WeightType.LIGHT

var CurrentHealth : float = 100

@export_category("References")
@export var AttackComp : AttackComponent
@export var DamageableComps : Array[DamageableComponent]


func _ready():
	Initialize()

func Initialize():
	for comp in DamageableComps:
		if !comp: continue
		comp.OnDamageTaken.connect(TakeDamage)

func TakeDamage(attackData:AttackData):
	# Checks to make sure the recieved attack isnt your own - to not hurt thineself
	if attackData.AttackOwner == self: 
		print("HIT> AttackOwner: "+ attackData.AttackOwner.name + ", Receiver: " + name)
		return
	print("RECIVE DAMAGE> AttackOwner: "+ attackData.AttackOwner.name + ", Receiver: " + name)
	
	AttackData.DebugAttackData(attackData)
	pass


func Die():
	queue_free()
	pass
