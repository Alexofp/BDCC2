extends ClothingBase

func _init():
	super._init()
	
	id = "TestTShirt"

func getItemSlots() -> Array:
	return [InventorySlot.Chest]

func getMeshPath() -> String:
	return "res://Mesh/Clothing/SimpleTshirt/t_shirt.tscn"
