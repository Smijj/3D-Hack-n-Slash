class_name AttackComponent
extends Area3D

signal AttackHit

@export_category("Attack Settings")
@export var BaseDamage : float = 10
@export var BaseKnockback : float = 10
@export var _RaycastCollisionMask:int = 16

@export_category("References")
@export var _Collider : CollisionShape3D 
@export var _DebugMeshInstance:MeshInstance3D

# Attack Info - gets set when in the Attack function
var _CurrentAttackData : AttackData
var _AttackType : CONSTS.AttackType = CONSTS.AttackType.BASIC
var _AttackOwner : Node
var _ResetAttackTween : Tween
var _ResetDebugMeshTween : Tween


#region Core Functions & Events 

func _ready():
	# If there is no collider, find it in children
	if !_Collider: _Collider = GetColliderInChildren()
	# If there was no collider in this node's children, create a new one
	if !_Collider: 
		_Collider = CollisionShape3D.new()
		add_child(_Collider)
	
	if !_DebugMeshInstance:
		_DebugMeshInstance = MeshInstance3D.new()
		_Collider.add_child(_DebugMeshInstance)
	
	# Make sure the attack is properly intialized
	_ResetAttackCollider()
	
	# Connect events
	area_entered.connect(_OnAttackHitboxCollision)

func GetColliderInChildren() -> CollisionShape3D:
	for node in get_children():
		if node is CollisionShape3D:
			return node
	return null

func _OnAttackHitboxCollision(area):
	if !_CurrentAttackData or _CurrentAttackData.AttackOwner == null: return
	if !area is DamageableComponent: return		# Make sure the area entered is a DmgComp
	# Checks if the area hit is part of the same tree as the AttackOwner
	if area.find_parent(_CurrentAttackData.AttackOwner.name) != null: 
		return	# Return if the attack hit its parent's dmgComp 
	
	# Pass AttackData through to the DmgComp
	var dmgComp : DamageableComponent = area
	dmgComp.RecieveAttack(_CurrentAttackData)
	
	# Sent out signal that an attack has sucessfully hit
	AttackHit.emit()

#endregion

### Creates new AttackData, aims and sizes the attack hitbox, and turns on the AttackComponent's hitbox briefly before turning it off again.
func Attack(attackOwner:Node, attackType:CONSTS.AttackType = CONSTS.AttackType.BASIC, attackTargetPos:Vector3 = -transform.basis.z, momentumMultiplier:float = 1):
	if !attackOwner or !_Collider: return
	print(attackOwner.name + " attacked")	# Debug
	
	## Create new AttackData
	_CurrentAttackData = AttackData.new()
	_CurrentAttackData.AttackOwner = attackOwner
	_CurrentAttackData.AttackType = attackType
	_CurrentAttackData.BaseDamage = BaseDamage * momentumMultiplier
	_CurrentAttackData.BaseKnockback = BaseKnockback * momentumMultiplier
	
	# If the target pos is within a certain range (to close), make the attack comp look straight ahead so the hitbox doesnt go out at weird angles.
	if global_position.distance_to(attackTargetPos) < 3:
		rotation = Vector3.ZERO
	else:
		# Make the Attack Comp look at the AttackTargetPos so that any hitboxes are aimed towards the target pos 
		look_at(attackTargetPos)
	
	## Colliders
	var attackShape:BoxShape3D = BoxShape3D.new()
	attackShape.size = CONSTS.GetAttackShapeSize(attackType, momentumMultiplier)
	_Collider.shape = attackShape
	_Collider.position.z = -attackShape.size.z/2	# Offsets the shape forward by half its size on the z-axis 
	
	# Turn collider off -> on -0.05s-> off to make sure any collisions that are already inside the collider get detected
	if _ResetAttackTween: _ResetAttackTween.kill()		# Kill any ResetAttack tween that was already playing
	_ResetAttackCollider()								# Reset the attack in case the ResetAttackTween wasnt able to do do before being killed
	_Collider.disabled = false
	_ResetAttackTween = create_tween()
	_ResetAttackTween.tween_callback(_ResetAttackCollider).set_delay(0.05)	# Tween that turns on attack hitbox for 0.05 seconds
	
	## Play Animation
	
	
	# DEBUG: mesh to visualize collisions
	var mesh:BoxMesh = BoxMesh.new()
	mesh.size = attackShape.size
	_DebugMeshInstance.mesh = mesh
	var mat:StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color.DARK_ORANGE
	_DebugMeshInstance.material_override = mat
	
	if _ResetDebugMeshTween: _ResetDebugMeshTween.kill()		# Kill any _ResetDebugMeshTween tween that was already playing
	_ResetDebugMeshTween = create_tween()
	_ResetDebugMeshTween.tween_callback(func(): _DebugMeshInstance.mesh = null).set_delay(0.2)

func _ResetAttackCollider():
	if !_Collider or _Collider.disabled == true: return
	_Collider.disabled = true

