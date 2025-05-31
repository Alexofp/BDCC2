extends ClothingSceneSelector

func _init() -> void:
	priority = 0.0
	itemID = "Blindfold"
	
	sceneByBodypartID = {
		"FelineHead": "res://Mesh/Parts/Head/FelineHead/Items/Blindfold/feline_blindfold.tscn",
		"HumanFeminineHead": "res://Mesh/Parts/Head/HumanFeminine/Items/Blindfold/fem_human_blindfold.tscn",
	}
