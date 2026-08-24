extends BodypartHairBase

func _init():
	super._init()
	id = "CoolBangsHair"

	mascWeight = 0.02
	femWeight = 1.0
	androWeight = 1.0

func getName() -> String:
	return "Cool bangs hair"

func getOptions() -> Dictionary:
	return super.getOptions()

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Hair/CoolBangsHair/cool_bangs_hair.tscn"
