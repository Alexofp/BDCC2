extends ClothingSceneSelector

func _init() -> void:
	priority = 0.0
	itemID = "Armbinder"
	
	bodypartSlot = BodypartSlot.Body
	sceneByBodypartID = {
		"FeminineBody": "res://Mesh/Clothing/Armbinder/armbinder.tscn",
		"MasculineBody": "res://Mesh/Clothing/Armbinder/armbinder_male.tscn",
	}
