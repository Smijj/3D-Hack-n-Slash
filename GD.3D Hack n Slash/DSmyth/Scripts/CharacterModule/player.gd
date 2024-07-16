extends Character
# Handles Player Input, Momentum, Dashing, and Jumping
@export_category("Player Settings")

@export_group("Movement")
@export var _AccelerationTime : float = 3
@export var _DeccelerationTime : float = 3
@export var _JumpVelocity : float = 10
@export var _AirControlMultiplier : float = 0.25 
var _XAccelerationTimeCounter := 0.0
var _ZAccelerationTimeCounter := 0.0
var _DeccelerationTimeCounter := 0.0

@export_group("Momentum")
@export var _MaxMomentum : float = 100
@export var _CurrentMomentum : float = 0:
	set(value): _CurrentMomentum = clampf(value, 0, _MaxMomentum)
@export var _MaxMomentumMuliplier : float = 2
@export var _MomentumDecayRate : float = 1
@export var _MomentumDecayDelay : float = 3
var _MomentumDecayDelayCounter : float = 0
var _IsMoving := false
var _MomentumMultiplier : float = 1: 
	get: 
		var momentumPercent = _CurrentMomentum/_MaxMomentum
		return lerpf(1, _MaxMomentumMuliplier, momentumPercent)

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
		_CurrentMomentum += 5 * delta
		if _MomentumDecayDelayCounter != 0: _MomentumDecayDelayCounter = 0
	else:
		if _MomentumDecayDelayCounter < _MomentumDecayDelay: _MomentumDecayDelayCounter += delta
	
	if _CurrentMomentum > 0 and _MomentumDecayDelayCounter >= _MomentumDecayDelay:
		_CurrentMomentum -= _MomentumDecayRate * delta
	

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
		_CurrentMomentum += 10
	

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


var _LastXInputDir = 0
var _LastZInputDir = 0
func _HandleMovement(delta):
	# Get the input direction and handle the movement/deceleration.
	var inputDir := Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBack")
	var direction := (basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
	var moveSpeed := MoveSpeed * _MomentumMultiplier
	var accelerationTime := _AccelerationTime
	if !is_on_floor():
		accelerationTime /= _AirControlMultiplier
	
	if direction:
		_IsMoving = true
		if signi(_LastXInputDir) != signi(inputDir.x):
			_XAccelerationTimeCounter = 0
		if signi(_LastZInputDir) != signi(inputDir.y):
			_ZAccelerationTimeCounter = 0

		_LastXInputDir = inputDir.x
		_LastZInputDir = inputDir.y
		
		_DeccelerationTimeCounter = 0
		if absf(_XAccelerationTimeCounter) < accelerationTime: _XAccelerationTimeCounter += delta * signf(inputDir.x)
		if absf(_ZAccelerationTimeCounter) < accelerationTime: _ZAccelerationTimeCounter += delta * signf(inputDir.y)
		#velocity.x = direction.x * lerpf(velocity.x, moveSpeed, absf(_XAccelerationTimeCounter)/accelerationTime)
		velocity.x = direction.x * MoveSpeed
		print("X: "+str(velocity.x))
		#velocity.z = lerpf(velocity.z, direction.z * moveSpeed, absf(_ZAccelerationTimeCounter)/accelerationTime)
		velocity.z = direction.z * MoveSpeed
		print("Z: "+str(velocity.z))
	else:
		_IsMoving = false
		_XAccelerationTimeCounter = 0
		_ZAccelerationTimeCounter = 0
		if _DeccelerationTimeCounter < accelerationTime: _DeccelerationTimeCounter += delta
		
		velocity.x = move_toward(velocity.x, 0, moveSpeed)
		velocity.z = move_toward(velocity.z, 0, moveSpeed)
		
		#if is_on_floor():
			#_SlowDownHorizontalVelocity(_DeccelerationTimeCounter/_DeccelerationTime)
		#else:
			#_SlowDownHorizontalVelocity(_DeccelerationTimeCounter/(_DeccelerationTime*2))

func _SlowDownHorizontalVelocity(weight:float):
	velocity.x = lerpf(velocity.x, 0, weight)
	velocity.z = lerpf(velocity.z, 0, weight)
	
