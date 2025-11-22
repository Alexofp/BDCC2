extends ClothingSceneSelector

func _init() -> void:
	priority = 0.0
	itemID = "PlainBra"
	
	sceneByBodypartID = {
		"FeminineBody": "res://Mesh/Clothing/PlainBra/plain_bra_fem.tscn",
		"MasculineBody": "res://Mesh/Clothing/PlainBra/plain_bra_fem_male.tscn",
	}
