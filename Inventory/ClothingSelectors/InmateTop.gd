extends ClothingSceneSelector

func _init() -> void:
	priority = 0.0
	itemID = "InmateTop"
	
	sceneByBodypartID = {
		"FeminineBody": "res://Mesh/Clothing/InmateTop/inmate_top.tscn",
	}
