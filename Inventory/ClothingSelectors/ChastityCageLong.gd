extends ClothingSceneSelector

func _init() -> void:
	priority = 0.0
	itemID = "ChastityCageLong"
	
	bodypartSlot = BodypartSlot.Penis
	sceneByBodypartID = {
		"HumanPenis": "res://Mesh/Clothing/ChastityCages/CageLong.tscn",
		"CaninePenis": "res://Mesh/Clothing/ChastityCages/CageLong.tscn",
	}
