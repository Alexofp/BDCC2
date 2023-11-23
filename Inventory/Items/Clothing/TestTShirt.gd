extends ClothingBase

func _init():
	super._init()
	
	id = "TestTShirt"

func getItemSlots() -> Array:
	return [InventorySlot.Chest]
