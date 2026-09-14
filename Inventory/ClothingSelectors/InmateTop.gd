extends ClothingSceneSelector

func _init() -> void:
	priority = 0.0
	itemID = "InmateTop"
	
	bodypartSlot = BodypartSlot.Body
	sceneByBodypartID = {
		"FeminineBody": "res://Mesh/Clothing/InmateTop/inmate_top.tscn",
		"MasculineBody": "res://Mesh/Clothing/InmateTop/inmate_top_male.tscn",
	}
