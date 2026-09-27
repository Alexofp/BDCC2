extends "res://Inventory/Items/InmateTop.gd"

func _init():
	super._init()
	id = "InmateTankTop"

func getName() -> String:
	return "Inmate tank top"

func getBuyPrice() -> int:
	return 5

func getItemValues() -> Array[ItemValue]:
	return [
		ItemValue.baseValue(0.5),
		ItemValue.itemValueTagBased(ItemValueTag.InmateClothing, 1.0),
	]
