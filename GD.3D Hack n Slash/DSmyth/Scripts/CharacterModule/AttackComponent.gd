class_name AttackComponent
extends Area3D

@export_category("Attack Settings")
@export var BaseDamage : float = 10
@export var BaseKnockback : float = 10
@export var _RaycastCollisionMask:int = 16

@export_category("References")
@export var _Collider : CollisionShape3D 
@export var _DebugMeshInstance:MeshInstance3D

# Attack Info - gets set when in the Attack function
var _AttackType : CONSTS.AttackType = CONSTS.AttackType.BASIC
var _AttackOwner : Node
var _ResetAttackTween : Tween


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
	if _AttackOwner == null: return
	if !area is DamageableComponent: return		# Make sure the area entered is a DmgbleComp
	
	# Setup AttackData
	var newAttackData = AttackData.new()
	newAttackData.AttackOwner = _AttackOwner
	newAttackData.AttackType = _AttackType
	newAttackData.BaseDamage = BaseDamage
	newAttackData.BaseKnockback = BaseKnockback
	
	# Pass AttackData through to the DmgComp
	var dmgComp : DamageableComponent = area
	dmgComp.RecieveAttack(newAttackData)

#endregion

### Turns on the AttackComponent's hitbox briefly
func Attack(attackOwner:Node, attackType:CONSTS.AttackType = CONSTS.AttackType.BASIC, attackTargetPos:Vector3 = -transform.basis.z):
	if !attackOwner or !_Collider: return
	print(attackOwner.name + " attacked")	# Debug
	
	# Set Attack info
	_AttackOwner = attackOwner
	_AttackType = attackType
	
	# Make the Attack Comp look at the AttackTargetPos so that any hitboxes are aimed towards the target pos 
	look_at(attackTargetPos)
	
	
	## Raycasts
	var rayExclusions:Array[RID]
	if attackOwner is PhysicsBody3D:
		rayExclusions.append(attackOwner.get_rid())		# Exclude the attack owner's physics body from being detected by the raycast
	
	# Shoot ray from _Collider pos to wherever the Camera was looking. this is to have the attacks feel like they are coming from the player char not the camera.
	var space:PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	#var query:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(global_position, attackTargetPos, _RaycastCollisionMask, rayExclusions)
	var query:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(global_position, attackTargetPos)
	query.exclude = rayExclusions
	var collision:Dictionary = space.intersect_ray(query)
	
	print("Exclusions: "+str(query.exclude))
	print("Collision: "+str(collision))
	
	#if collision:
		#print("Attack Raycast Hit Something lol")
		#print(collision)
	
	
	## Colliders
	var attackShapeSize = Vector3(1,1,global_position.distance_to(attackTargetPos))
	var attackShape:BoxShape3D = BoxShape3D.new()
	attackShape.size = attackShapeSize
	_Collider.shape = attackShape
	_Collider.position.z = -attackShapeSize.z/2
	
	# Debug mesh to visualize collisions
	var mesh:BoxMesh = BoxMesh.new()
	mesh.size = attackShapeSize
	_DebugMeshInstance.mesh = mesh
	
	# Turn collider off -> on -> off to make sure any collisions that are already inside the collider get detected
	if _ResetAttackTween: _ResetAttackTween.kill()		# Kill any ResetAttack tween that was already playing
	_ResetAttackCollider()								# Reset the attack in case the ResetAttackTween wasnt able to do do before being killed
	_Collider.disabled = false
	_ResetAttackTween = create_tween()
	_ResetAttackTween.tween_callback(_ResetAttackCollider).set_delay(0.05)	# Tween that turns on attack hitbox for 0.05 seconds
	
	# Play Animation
	

func _ResetAttackCollider():
	if !_Collider or _Collider.disabled == true: return
	_Collider.disabled = true
	
	#if _DebugMeshInstance: _DebugMeshInstance.mesh = null

