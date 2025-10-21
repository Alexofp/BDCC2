extends PersonalityStatBase

func _init() -> void:
	id = PersonalityStat.Dominant
	priority = 9.0

func getVisibleName() -> String:
	return "Dominant"

func getNamePositive() -> String:
	return "Dominant"

func getNameNegative() -> String:
	return "Submissive"
