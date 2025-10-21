extends PersonalityStatBase

func _init() -> void:
	id = PersonalityStat.Brave
	priority = 7.0

func getVisibleName() -> String:
	return "Brave"

func getNamePositive() -> String:
	return "Brave"

func getNameNegative() -> String:
	return "Soft"
