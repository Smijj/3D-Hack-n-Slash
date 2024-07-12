class_name Character
extends CharacterBody3D

@export var StatsComp : StatsComponent
@export var AttackComp : AttackComponent
@export var DamageableComps : Array[DamageableComponent]


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready():
	
	for comp in DamageableComps:
		comp.OnDamageTaken.connect(StatsComp.TakeDamage)
		pass

	pass

func _physics_process(delta):
	HandleMovement(delta)
	move_and_slide()

func HandleMovement(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var inputDir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBack")
	var direction = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func Attack():
	pass

func Die():
	pass


