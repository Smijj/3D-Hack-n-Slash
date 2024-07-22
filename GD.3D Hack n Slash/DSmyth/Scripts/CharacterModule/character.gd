class_name Character
extends CharacterBody3D

@export_category("Character Settings")

@export_group("Movement")
@export var MoveSpeed : float = 15
var _Gravity = ProjectSettings.get_setting("physics/3d/default_gravity")	# Get the Gravity from the project settings to be synced with RigidBody nodes.

@export_group("Stats")
signal HealthChanged(currentHealth:float, currentHealthPercentage:float)

@export var MaxHealth : float = 100
@export var _WeightType : CONSTS.WeightType = CONSTS.WeightType.LIGHT
var _CurrentHealth : float:
	get: return _CurrentHealth
	set(value): 
		_CurrentHealth = clampf(value, 0, MaxHealth) 
		HealthChanged.emit(_CurrentHealth, _CurrentHealthPercentage)
var _CurrentHealthPercentage : float:
	get: return clampf(_CurrentHealth / MaxHealth, 0, 1) 

@export_group("References")
@export var AttackComp : AttackComponent
@export var DamageableComps : Array[DamageableComponent]


#region Core + Events

func _ready():
	_CurrentHealth = MaxHealth
	
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
	if attackData.AttackOwner == self: return
	
	var postMidigationDamage = attackData.CalculatePostMidigationDamage(_WeightType)
	_CurrentHealth -= postMidigationDamage
	
	print("RECEIVED DAMAGE> AttackOwner: "+ attackData.AttackOwner.name + ", Receiver: " + name + ", Amount: " + str(postMidigationDamage) + ", CurrentHealth: " + str(_CurrentHealth))
	attackData.Debug()
	
	if _CurrentHealth <= 0: Die()


func Die():
	queue_free()
	pass
