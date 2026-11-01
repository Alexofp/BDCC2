extends CharacterTypeBase

func _init() -> void:
	id = CharacterType.Generic

	inmate = false
	staff = false
	allowPickAsPlayer = false

func getName() -> String:
	return "Generic"
