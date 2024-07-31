extends Character
# Handles Player Input, Momentum, Dashing, and Jumping
@export_category("Player Settings")

@export_group("Movement")
@export var _AccelerationRate : float = 6
@export var _JumpVelocity : float = 10
@export var _AirControlMultiplier : float = 0.25 

@export_group("Momentum")
signal MomentumChanged(momentumPercentage:float, momentumMultiplier:float)

@export var _MaxMomentum : float = 100
@export var CurrentMomentum : float = 0:
	set(value): 
		CurrentMomentum = clampf(value, 0, _MaxMomentum)
		MomentumChanged.emit(_MomentumPercentage, _MomentumMultiplier)
@export var _NumberOfMomentumCharges:int = 3
@export var _MaxMomentumMuliplier : float = 2
@export var _MomentumDecayRate : float = 10
@export var _MomentumDecayDelay : float = 1.5
@export var _MovementMomentumGain : float = 3
var _MomentumDecayDelayCounter : float = 0
var _IsMoving := false
var _MomentumPercentage : float = 0:
	get: return CurrentMomentum/_MaxMomentum
var _MomentumMultiplier : float = 1: 
	get: 
		var weight:float = 0
		for i:int in range(_NumberOfMomentumCharges,0,-1):		# Clamps the weight value to a step-percentage based on the number of momentum charges the player has. I.e. 3 Charges means the weight will clamped to [0.33, 0.66, & 1]
			var stepPercentage :float = i/float(_NumberOfMomentumCharges)
			if _MomentumPercentage >= stepPercentage:
				weight = stepPercentage
				break
		return lerpf(1, _MaxMomentumMuliplier, weight)

@export_group("Dash")
@export var _DashCD : float = 0.5
@export var _DashDistance : float = 10
@export var _DashTravelTime : float = 0.4
@export var _DashExitVelocity : float = 10
var _DashingTween : Tween

@export_group("Attack")
signal AttackTypeChanged(newAttackType:CONSTS.AttackType)
@export var _AttackCooldown: float = 0.4
@export var _AttackHitMomentumGain: float = 2
@export var _CurrentAttackType : CONSTS.AttackType
var _AttackCooldownCounter: float = 0

@export_group("Camera")
@export var _MouseSensitivity := 0.2
@export var _CameraPivot :Node3D
@export var _CameraLookingPos :Node3D


#region Core Functions & Events

# Override Func
func Initialize():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if !_CameraPivot: 
		printerr("No Player CameraPivot node set!")
		push_error("No Player CameraPivot node set!")
	
	if AttackComp: AttackComp.AttackHit.connect(_OnAttackHit)
	else: 
		printerr("No Player _AttackComp node set!")
		push_error("No Player _AttackComp node set!")
		


# Override Func
func PhysicsUpdate(delta):
	_HandleMovement(delta)

func _process(delta):
	_HandleMomentum(delta)
	
	# Basic attack CD
	if _AttackCooldownCounter > 0:
		_AttackCooldownCounter -= delta

func _input(event:InputEvent):
	# Handle Jump
	if event.is_action_pressed("Jump") and is_on_floor():
		velocity.y = _JumpVelocity
	# Handle Dash
	if event.is_action_pressed("Dash"):
		_Dash()
	
	_HandleCamera(event)	# Handle Camera and player y rotation
	
	_HandleAttacking(event)

func _OnAttackHit():
	CurrentMomentum += _AttackHitMomentumGain

#endregion


#region Private Functions

func _HandleMomentum(delta):
	# If the player is moving increase their momentum. If they stop moving start the Momentum Decay Delay counter
	if _IsMoving:
		CurrentMomentum += _MovementMomentumGain * delta
		if _MomentumDecayDelayCounter != 0: _MomentumDecayDelayCounter = 0
	else:
		if _MomentumDecayDelayCounter < _MomentumDecayDelay: _MomentumDecayDelayCounter += delta
	
	# After a delay (if the player stops moving for long enough), start decaying the players momentum
	if CurrentMomentum > 0 and _MomentumDecayDelayCounter >= _MomentumDecayDelay:
		CurrentMomentum -= _MomentumDecayRate * delta


func _HandleAttacking(event:InputEvent):
	# Normal attack
	if _AttackCooldownCounter <= 0 and event.is_action_pressed("Attack"):
		if AttackComp: AttackComp.Attack(self, _CurrentAttackType, _CameraLookingPos.global_position, _MomentumMultiplier)
		_ChangeAttackType(CONSTS.AttackType.BASIC)	# Reset attacktype to BASIC after attacking
		_AttackCooldownCounter = _AttackCooldown	# Set cooldown timer
	
	# Empower toggles
	if event.is_action_pressed("Empower0"):
		# If the _CurrentAttackType was already PIERCING, toggle it back to BASIC. Otherwise set it to PIERCING.
		if _CurrentAttackType == CONSTS.AttackType.PIERCING:
			_ChangeAttackType(CONSTS.AttackType.BASIC)
		else: _ChangeAttackType(CONSTS.AttackType.PIERCING)
	
	if event.is_action_pressed("Empower1"):
		# If the _CurrentAttackType was already BLUNT, toggle it back to BASIC. Otherwise set it to BLUNT.
		if _CurrentAttackType == CONSTS.AttackType.BLUNT:
			_ChangeAttackType(CONSTS.AttackType.BASIC)
		else: _ChangeAttackType(CONSTS.AttackType.BLUNT)

func _ChangeAttackType(newAttackType:CONSTS.AttackType):
	_CurrentAttackType = newAttackType
	AttackTypeChanged.emit(_CurrentAttackType)


func _Dash():
	if _DashingTween: _DashingTween.kill()
	_DashingTween = create_tween()
	_DashingTween.tween_method(_MovePlayer, position, position + (-transform.basis.z * _DashDistance), _DashTravelTime)
	_DashingTween.set_ease(Tween.EASE_OUT)
	_DashingTween.set_trans(Tween.TRANS_EXPO)
	_DashingTween.finished.connect(func(): velocity = -transform.basis.z * _DashExitVelocity, CONNECT_ONE_SHOT)
	
func _MovePlayer(newPosition):
	position.x = newPosition.x
	position.z = newPosition.z

func _HandleCamera(event:InputEvent):
	if not event is InputEventMouseMotion: return
	
	# Rotate whole player around the y axis to look left and right
	rotate_y(deg_to_rad(-event.relative.x * _MouseSensitivity))
	# Rotate just the camera around the x axis to look up and down
	if _CameraPivot:
		_CameraPivot.rotate_x(deg_to_rad(-event.relative.y * _MouseSensitivity))
		_CameraPivot.rotation.x = clamp(_CameraPivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))	# Clamp camera up/down motion

func _HandleMovement(delta):
	var maxVelocity := MoveSpeed * _MomentumMultiplier
	var accelerationRate := _AccelerationRate

	# Get the input direction and handle the movement/deceleration.
	var inputDir := Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBack")
	var direction := (basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
	var moveVector := direction * maxVelocity
	
	if !is_on_floor():
		# TODO: Currently this doesnt work as the acceleration rate is only applied when slowing the player down
		accelerationRate *= _AirControlMultiplier	# Causing the player to accelerate and decelerate more slowly while in the air

	if direction:
		_IsMoving = true
		velocity.x = direction.x * maxVelocity
		velocity.z = direction.z * maxVelocity
	else:
		_IsMoving = false
		velocity.x = move_toward(velocity.x, 0, accelerationRate)
		velocity.z = move_toward(velocity.z, 0, accelerationRate)

#endregion
