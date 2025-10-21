extends PersonalityStatBase

func _init() -> void:
	id = PersonalityStat.Perceptive
	priority = 8.0

func getVisibleName() -> String:
	return "Perceptive"

func getNamePositive() -> String:
	return "Perceptive"

func getNameNegative() -> String:
	return "Naive"
