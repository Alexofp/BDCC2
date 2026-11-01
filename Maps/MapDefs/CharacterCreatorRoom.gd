extends MapDef

func _init() -> void:
	id = "CharacterCreatorRoom"
	gamemodes = [GameMode.CharacterCreator]
	scenePath = "res://Maps/CharacterCreatorRoom/character_creator_room.tscn"

func getName() -> String:
	return "Character creator room"
