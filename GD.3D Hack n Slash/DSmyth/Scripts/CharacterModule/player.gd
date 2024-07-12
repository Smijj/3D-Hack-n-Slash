extends Character

func _input(event):
	# Gets player input
	if event.is_action_pressed("Attack"):
		if AttackComp: AttackComp.Attack(self, Constants.AttackType.BASIC)
	pass
	
