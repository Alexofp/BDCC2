extends PersonalityStatBase

func _init() -> void:
	id = PersonalityStat.Bratty
	priority = 6.0

func getVisibleName() -> String:
	return "Bratty"

func getNamePositive() -> String:
	return "Bratty"

func getNameNegative() -> String:
	return "Obedient"
