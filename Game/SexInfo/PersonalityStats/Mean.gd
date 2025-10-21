extends PersonalityStatBase

func _init() -> void:
	id = PersonalityStat.Mean
	priority = 10.0

func getVisibleName() -> String:
	return "Mean"

func getNamePositive() -> String:
	return "Mean"

func getNameNegative() -> String:
	return "Kind"
