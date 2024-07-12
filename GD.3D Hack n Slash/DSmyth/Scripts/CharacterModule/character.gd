class_name Character
extends CharacterBody3D

@export_category("Settings")
@export var MoveSpeed = 5.0
@export var JumpVelocity = 4.5

@export_category("References")
@export var StatsComp : StatsComponent
@export var AttackComp : AttackComponent
@export var DamageableComps : Array[DamageableComponent]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	if !StatsComp or DamageableComps.size() == 0: return
	for comp in DamageableComps:
		comp.OnDamageTaken.connect(StatsComp.TakeDamage)

func _physics_process(delta):
	HandleMovement(delta)
	move_and_slide()

func HandleMovement(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JumpVelocity

	# Get the input direction and handle the movement/deceleration.
	var inputDir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBack")
	var direction = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
	if direction:
		velocity.x = direction.x * MoveSpeed
		velocity.z = direction.z * MoveSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, MoveSpeed)
		velocity.z = move_toward(velocity.z, 0, MoveSpeed)


func Die():
	pass


