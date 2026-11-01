extends GameModeDef

func _init() -> void:
	id = GameMode.CharacterCreator
	scenePath = "res://Game/Mode/Modes/CharacterCreator/CharacterCreator.tscn"

func getName() -> String:
	return "Character Creator"

func getSettings() -> Dictionary:
	return {}

func getMapID() -> String:
	return "CharacterCreatorRoom"
