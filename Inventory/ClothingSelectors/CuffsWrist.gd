extends ClothingSceneSelector

func _init() -> void:
	priority = 0.0
	itemID = "CuffsWrist"
	
	sceneByBodypartID = {
		"FeminineBody": "res://Mesh/Clothing/InmateCuffs/inmate_wrist_cuffs.tscn",
	}
