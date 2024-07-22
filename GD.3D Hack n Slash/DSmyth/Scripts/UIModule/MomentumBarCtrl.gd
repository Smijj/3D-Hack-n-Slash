extends ProgressBar

func _ready():
	value = 0
	max_value = 1

func _OnMomentumChanged(percentValue:float, momentumMultiplier:float):
	_UpdateProgressBarValue(percentValue)

func _UpdateProgressBarValue(percentValue:float):
	value = percentValue
