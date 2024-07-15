extends Character
# Handles Player Input, Momentum, Dashing, and Jumping

@onready var CameraPivot = $CameraOrigin
@export var Sens := 0.5

#region Godot Functions & Events

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	HandleMovement(delta)
	move_and_slide()

func _input(event):
	
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * Sens))
		CameraPivot.rotate_x(deg_to_rad(-event.relative.y * Sens))
		CameraPivot.rotation.x = clamp(CameraPivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))
	
	if event.is_action_pressed("Attack"):
		if AttackComp: AttackComp.Attack(self, Constants.AttackType.BASIC)
	pass

#endregion


func HandleMovement(delta):
	# Add the Gravity.
	if not is_on_floor():
		velocity.y -= Gravity * delta

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
