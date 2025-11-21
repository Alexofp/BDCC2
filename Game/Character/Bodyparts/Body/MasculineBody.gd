extends BodypartBodyBase

func _init():
	super._init()
	id = "MasculineBody"
	skinType = SkinType.Auto

func getName() -> String:
	return "Masculine body"

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Body/MasculineBody/masculine_body.tscn"

func getSupportedSkinTypes() -> Dictionary:
	return {
		SkinType.Auto: true,
		SkinType.HumanSkin: true,
		SkinType.Fur: true,
	}
