extends BodypartBodyBase

func _init():
	super._init()
	id = "FeminineBody"
	skinType = SkinType.Auto

func getName() -> String:
	return "Feminine body"

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Body/FeminineBody/feminine_body.tscn"

func getSupportedSkinTypes() -> Dictionary:
	return {
		SkinType.Auto: true,
		SkinType.HumanSkin: true,
		SkinType.Fur: true,
	}
