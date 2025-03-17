extends BodypartBodyBase

func _init():
	id = "FeminineBody"
	skinType = SkinType.HumanSkin

func getName() -> String:
	return "Feminine body"

func getScenePath(_slot:String) -> String:
	return "res://Mesh/Parts/Body/FeminineBody/feminine_body.tscn"

func getSupportedSkinTypes() -> Dictionary:
	return {
		SkinType.HumanSkin: true,
		SkinType.Fur: true,
	}
