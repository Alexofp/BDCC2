extends "res://Game/Character/Type/Types/InmateGeneral.gd"

func _init() -> void:
	super._init()
	id = CharacterType.InmateSexToy
	scoreBase = 0.7

	colorMain = Color("9900ffff")

func getName() -> String:
	return "Inmate (SexToy)"
