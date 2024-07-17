class_name Character
extends CharacterBody3D

@export_category("Character Settings")

@export_group("Movement")
@export var MoveSpeed : float = 15
# Get the Gravity from the project settings to be synced with RigidBody nodes.
var _Gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_group("Stats")
@export var MaxHealth : float = 100
@export var WeightType : Constants.WeightType = Constants.WeightType.LIGHT
var _CurrentHealth : float = 100

@export_group("References")
@export var AttackComp : AttackComponent
@export var DamageableComps : Array[DamageableComponent]


#region Core + Events

func _ready():
	for comp in DamageableComps:
		if !comp: continue
		comp.OnDamageTaken.connect(TakeDamage)
	Initialize()

# Virtual Func
func Initialize():
	pass

func _physics_process(delta):
	# Handle Gravity
	if not is_on_floor():
		velocity.y -= _Gravity * delta
	
	PhysicsUpdate(delta)
	move_and_slide()

# Virtual Func
func PhysicsUpdate(delta):
	pass

#endregion


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
