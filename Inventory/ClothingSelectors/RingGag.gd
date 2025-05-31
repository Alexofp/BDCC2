extends ClothingSceneSelector

func _init() -> void:
	priority = 0.0
	itemID = "RingGag"
	
	sceneByBodypartID = {
		"FelineHead": "res://Mesh/Parts/Head/FelineHead/Items/GagHarness/feline_gag_harness.tscn",
		"HumanFeminineHead": "res://Mesh/Parts/Head/HumanFeminine/Items/GagHarness/fem_human_gag_harness.tscn",
	}
