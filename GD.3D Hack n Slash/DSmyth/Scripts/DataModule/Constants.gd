class_name CONSTS

enum WeightType {
	LIGHT,
	HEAVY
}

enum AttackType {
	BASIC,
	PIERCING,
	BLUNT
}

enum DefenceType {
	SOFT,
	HARD
}

static var DamageMultiplierTable:Dictionary = {
	CONSTS.AttackType.BASIC : {
		CONSTS.WeightType.LIGHT : {
			CONSTS.DefenceType.SOFT : 1,
			CONSTS.DefenceType.HARD : 0.5
		},
		CONSTS.WeightType.HEAVY : {
			CONSTS.DefenceType.SOFT : 0.5,
			CONSTS.DefenceType.HARD : 0
		}
	},
	CONSTS.AttackType.PIERCING : {
		CONSTS.WeightType.LIGHT : {
			CONSTS.DefenceType.SOFT : 2,
			CONSTS.DefenceType.HARD : 0
		},
		CONSTS.WeightType.HEAVY : {
			CONSTS.DefenceType.SOFT : 3,
			CONSTS.DefenceType.HARD : 0
		}
	},
	CONSTS.AttackType.BLUNT : {
		CONSTS.WeightType.LIGHT : {
			CONSTS.DefenceType.SOFT : 1,
			CONSTS.DefenceType.HARD : 0
		},
		CONSTS.WeightType.HEAVY : {
			CONSTS.DefenceType.SOFT : 1.5,
			CONSTS.DefenceType.HARD : 2
		}
	},
}

#static func CalculateDamageModifer(attackType:CONSTS.AttackType = 0, weightType:CONSTS.WeightType = 0, defenceType:CONSTS.DefenceType = 0) -> float:
	#return _DamageMultiplierTable[attackType][weightType][defenceType]
