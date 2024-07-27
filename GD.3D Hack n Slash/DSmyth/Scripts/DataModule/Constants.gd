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

static func GetAttackShape(attackType:AttackType, rangeMultiplier:float) -> Vector3:
	var attackShape:Vector3 = _AttackShape[attackType]
	attackShape.z *= rangeMultiplier
	return attackShape

static var _AttackShape:Dictionary = {
	CONSTS.AttackType.BASIC : Vector3(8, 0.2, 5),
	CONSTS.AttackType.PIERCING : Vector3(1, 1, 7),
	CONSTS.AttackType.BLUNT : Vector3(6, 3.5, 4),
}

static func CalculateDamageModifer(attackType:CONSTS.AttackType = 0, weightType:CONSTS.WeightType = 0, defenceType:CONSTS.DefenceType = 0) -> float:
	return _DamageMultiplierTable[attackType][weightType][defenceType]

static var _DamageMultiplierTable:Dictionary = {
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
