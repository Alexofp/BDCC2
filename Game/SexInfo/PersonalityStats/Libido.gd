extends PersonalityStatBase

func _init() -> void:
	id = PersonalityStat.Libido
	priority = 5.0

func getVisibleName() -> String:
	return "Libido"

func getNamePositive() -> String:
	return "Lusty"

func getNameNegative() -> String:
	return "Cold"
