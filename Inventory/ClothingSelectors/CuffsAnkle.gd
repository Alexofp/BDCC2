extends ClothingSceneSelector

func _init() -> void:
	priority = 0.0
	itemID = "CuffsAnkle"
	
	sceneByBodypartID = {
		"FeminineBody": "res://Mesh/Clothing/InmateCuffs/inmate_ankle_cuffs.tscn",
	}
