extends ClothingBase

func _init():
	super._init()
	
	id = "TestHat"

func getItemSlots() -> Array:
	return [InventorySlot.Hat]

func getMeshStructure(_baseCharacter: BaseCharacter) -> Dictionary:
	return {
		"hat": {
			"attachTo": [BodypartSlot.Head],
			"attachSlot": "Hat",
			"path": "res://Mesh/Clothing/TestHat/TestHat.tscn",
		}
	}

func getMeshPath() -> String:
	return "res://Mesh/Clothing/SimpleTshirt/t_shirt.tscn"
