extends "res://Game/Character/Type/Types/InmateGeneral.gd"

func _init() -> void:
	super._init()
	id = CharacterType.InmateHighSec
	scoreBase = 0.7

	colorMain = Color("ff0000ff")

func getName() -> String:
	return "Inmate (HighSec)"
