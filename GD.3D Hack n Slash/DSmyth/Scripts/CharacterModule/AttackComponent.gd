class_name AttackComponent
extends Area3D

@export_category("Attack Settings")
@export var BaseDamage : float = 10
@export var BaseKnockback : float = 10

@export_category("References")
@export var _Collider : CollisionShape3D 

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
	
	# Make sure the attack is properly intialized
	_ResetAttack()
	
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
func Attack(attackOwner:Node, attackType:CONSTS.AttackType = CONSTS.AttackType.BASIC, cameraCollision:Dictionary = {}):
	if !attackOwner or !_Collider: return
	print(attackOwner.name + " attacked")	# Debug
	
	var targetPos:Vector3
	var attackRange:float = 30
	
	# if the camera raycast was intersecting anything when attempting to attack, use the intersect position
	if cameraCollision: 
		targetPos = cameraCollision["position"]
		print("CameraRaycast HitPos: "+str(targetPos))
	# Otherwise, make the targetPos somewhere in front of the Collider
	else: targetPos = _Collider.global_position - _Collider.global_transform.basis.z * attackRange
	
	# Shoot ray from _Collider pos to wherever the Camera was looking. this is to have the attacks feel like they are coming from the player char not the camera.
	var space:PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(_Collider.global_position, targetPos)
	var collision:Dictionary = space.intersect_ray(query)
	
	if collision:
		print("Attack Raycast Hit Something lol")
	
	## BUG: This doesnt quite work
	var attackShapeSize = Vector3(1,1,targetPos.z - _Collider.global_position.z)
	
	var attackShape:BoxShape3D = BoxShape3D.new()
	attackShape.size = attackShapeSize
	_Collider.shape = attackShape
	_Collider.position.z = -attackShapeSize.z/2
	_Collider.look_at(targetPos)
	
	# Debug mesh to visualize collisions
	var mesh:BoxMesh = BoxMesh.new()
	mesh.size = attackShapeSize
	var _DebugMeshInstance:MeshInstance3D = MeshInstance3D.new()	# TODO: Export this and just updated the Mesh comp with a new shape each time dumbass
	_DebugMeshInstance.mesh = mesh
	_Collider.add_child(_DebugMeshInstance)
	
	
	# Set Attack info
	_AttackOwner = attackOwner
	_AttackType = attackType
	
	if _ResetAttackTween: _ResetAttackTween.kill()		# Kill any ResetAttack tween that was already playing
	_ResetAttack()										# Reset the attack in case the ResetAttackTween wasnt able to do do before being killed
	_Collider.disabled = false
	_ResetAttackTween = create_tween()
	_ResetAttackTween.tween_callback(_ResetAttack).set_delay(0.2)	# Tween that turns on attack hitbox for 0.2 seconds
	
	# Play Animation
	

func _ResetAttack():
	if !_Collider or _Collider.disabled == true: return
	_Collider.disabled = true

