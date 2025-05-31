extends BodypartHeadBase

func _init():
	id = "HumanFeminineHead"
	skinType = SkinType.HumanSkin

func getName() -> String:
	return "Human Feminine head"

func getScenePath(_slot:int) -> String:
	return "res://Mesh/Parts/Head/HumanFeminine/my_human_head.tscn"

func getSupportedSkinTypes() -> Dictionary:
	return {
		SkinType.HumanSkin: true,
		SkinType.Fur: true,
	}
