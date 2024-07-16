extends Character

# Override Func
func Initialize():
	pass

# Override Func
func PhysicsUpdate(delta):
	pass

func _input(event):
	if event.is_action_pressed("TestEnemyAttack"):
		print(self.name + " is atttacking")
		AttackComp.Attack(self, Constants.AttackType.BASIC)
