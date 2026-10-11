extends GameModeDef

func _init() -> void:
	id = GameMode.CharacterCreator
	scenePath = "res://Game/Mode/Modes/CharacterCreator/CharacterCreator.tscn"

func getName() -> String:
	return "Character Creator"

func getSettings() -> Dictionary:
	return {}

func getMapScenePath() -> String:
	return "res://Maps/CharacterCreatorRoom/character_creator_room.tscn"
