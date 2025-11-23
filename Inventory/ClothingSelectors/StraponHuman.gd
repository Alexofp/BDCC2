extends ClothingSceneSelector

func _init() -> void:
	priority = 0.0
	itemID = "StraponHuman"
	
	sceneByBodypartID = {
		"FeminineBody": "res://Mesh/Clothing/StraponHarness/strapon_harness_human.tscn",
		"MasculineBody": "res://Mesh/Clothing/StraponHarness/strapon_harness_human_male.tscn",
	}
