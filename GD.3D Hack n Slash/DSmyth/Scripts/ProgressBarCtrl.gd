extends ProgressBar

func _ready():
	value = 0
	max_value = 1

func OnPercentValueChanged(percentValue):
	value = percentValue
