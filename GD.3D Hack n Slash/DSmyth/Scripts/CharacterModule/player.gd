extends Character
# Handles Player Input, Momentum, Dashing, and Jumping
@export_category("Player Settings")

@export_group("Movement")
@export var _AccelerationRate : float = 6
@export var _JumpVelocity : float = 10
@export var _AirControlMultiplier : float = 0.25 

@export_group("Momentum")
signal MomentumChanged(momentumPercentage)

@export var _MaxMomentum : float = 100
@export var CurrentMomentum : float = 0:
	set(value): 
		CurrentMomentum = clampf(value, 0, _MaxMomentum)
		MomentumChanged.emit(_MomentumPercentage)
@export var _MaxMomentumMuliplier : float = 2
@export var _MomentumDecayRate : float = 10
@export var _MomentumDecayDelay : float = 1.5
@export var _MovementMomentumGain : float = 3
var _MomentumDecayDelayCounter : float = 0
var _IsMoving := false
var _MomentumPercentage : float = 0:
	get: return CurrentMomentum/_MaxMomentum
var _MomentumMultiplier : float = 1: 
	get: return lerpf(1, _MaxMomentumMuliplier, _MomentumPercentage)

@export_group("Dash")
@export var _DashCD : float = 0.5
@export var _DashDistance : float = 10
@export var _DashTravelTime : float = 0.4
@export var _DashExitVelocity : float = 10
var _DashingTween : Tween

@export_group("Camera")
@export var _MouseSensitivity := 0.2
@onready var _CameraPivot :Node3D = $CameraOrigin


#region Godot Functions & Events

# Override Func
func Initialize():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Override Func
func PhysicsUpdate(delta):
	_HandleMovement(delta)

func _process(delta):
	if _IsMoving:
		CurrentMomentum += _MovementMomentumGain * delta
		if _MomentumDecayDelayCounter != 0: _MomentumDecayDelayCounter = 0
	else:
		if _MomentumDecayDelayCounter < _MomentumDecayDelay: _MomentumDecayDelayCounter += delta
	
	if CurrentMomentum > 0 and _MomentumDecayDelayCounter >= _MomentumDecayDelay:
		CurrentMomentum -= _MomentumDecayRate * delta
	

func _input(event):
	# Handle Jump
	if event.is_action_pressed("Jump") and is_on_floor():
		velocity.y = _JumpVelocity
	
	# Handle Camera
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * _MouseSensitivity))
		_CameraPivot.rotate_x(deg_to_rad(-event.relative.y * _MouseSensitivity))
		_CameraPivot.rotation.x = clamp(_CameraPivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))
	
	if event.is_action_pressed("Dash"):
		Dash()
	
	if event.is_action_pressed("Attack"):
		if AttackComp: AttackComp.Attack(self, Constants.AttackType.BASIC)
		
	if event.is_action_pressed("Empower1"):
		CurrentMomentum += 10
	

#endregion

func Dash():
	if _DashingTween: _DashingTween.kill()
	_DashingTween = create_tween()
	_DashingTween.tween_method(_MovePlayer, position, position + (-transform.basis.z * _DashDistance), _DashTravelTime)
	_DashingTween.set_ease(Tween.EASE_OUT)
	_DashingTween.set_trans(Tween.TRANS_EXPO)
	_DashingTween.finished.connect(func(): velocity = -transform.basis.z * _DashExitVelocity, CONNECT_ONE_SHOT)
	
func _MovePlayer(newPosition):
	position.x = newPosition.x
	position.z = newPosition.z


func _HandleMovement(delta):
	var maxVelocity := MoveSpeed * _MomentumMultiplier
	var accelerationRate := _AccelerationRate

	# Get the input direction and handle the movement/deceleration.
	var inputDir := Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBack")
	var direction := (basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
	var moveVector := direction * maxVelocity
	
	if !is_on_floor():
		accelerationRate *= _AirControlMultiplier	# Causing the player to accelerate and decelerate more slowly while in the air

	if direction:
		_IsMoving = true
		velocity.x = direction.x * maxVelocity
		velocity.z = direction.z * maxVelocity
	else:
		_IsMoving = false
		velocity.x = move_toward(velocity.x, 0, accelerationRate)
		velocity.z = move_toward(velocity.z, 0, accelerationRate)
