extends ClothingSceneSelector

func _init() -> void:
	priority = 0.0
	itemID = "InmateShorts"
	
	sceneByBodypartID = {
		"FeminineBody": "res://Mesh/Clothing/InmateShorts/InmateShorts.tscn",
		"MasculineBody": "res://Mesh/Clothing/InmateShorts/inmate_shorts_male.tscn",
	}
