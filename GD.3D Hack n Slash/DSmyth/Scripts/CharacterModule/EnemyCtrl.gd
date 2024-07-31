extends Character

# Override Func
func Initialize():
	pass

# Override Func
func PhysicsUpdate(delta):
	pass

func _input(event):
	if event.is_action_pressed("TestEnemyAttack"):
		AttackComp.Attack(self, CONSTS.AttackType.BASIC)
