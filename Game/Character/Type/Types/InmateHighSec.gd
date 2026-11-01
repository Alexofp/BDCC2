extends "res://Game/Character/Type/Types/InmateGeneral.gd"

func _init() -> void:
	super._init()
	id = CharacterType.InmateHighSec

	colorMain = Color("ff0000ff")

func getName() -> String:
	return "Inmate (HighSec)"
