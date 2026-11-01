extends CharacterTypeBase

func _init() -> void:
	id = CharacterType.Generic

	inmate = false
	staff = false
	allowPickAsPlayer = false
	scoreBase = 0.0

func getName() -> String:
	return "Generic"
