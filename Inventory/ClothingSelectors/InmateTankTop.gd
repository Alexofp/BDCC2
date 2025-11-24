extends ClothingSceneSelector

func _init() -> void:
	priority = 0.0
	itemID = "InmateTankTop"
	
	sceneByBodypartID = {
		"FeminineBody": "res://Mesh/Clothing/InmateTankTop/inmate_tank_top.tscn",
		"MasculineBody": "res://Mesh/Clothing/InmateTankTop/inmate_tank_top_male.tscn",
	}
