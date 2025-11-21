extends ClothingSceneSelector

func _init() -> void:
	priority = 0.0
	itemID = "LatexSuit"
	
	sceneByBodypartID = {
		"FeminineBody": "res://Mesh/Clothing/LatexSuit/latex_suit.tscn",
		"MasculineBody": "res://Mesh/Clothing/LatexSuit/latex_suit.tscn",
	}
