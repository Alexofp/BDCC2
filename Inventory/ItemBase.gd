extends RefCounted
class_name ItemBase

var id:String = "error"
var currentInventory:Inventory = null

func getVisibleName() -> String:
	return "(ERROR ITEM)"

## Which inventory slots does this item support.
## It's an array because we might have support for wearing multiple rings for example
func getItemSlots() -> Array:
	return []

func getInventory() -> Inventory:
	return currentInventory

func isEquipped() -> bool:
	if(currentInventory == null):
		return false
	return currentInventory.isItemEquipped(self)

func getMeshPath() -> String:
	return "res://Mesh/Clothing/SimpleTshirt/t_shirt.tscn"

func getMeshScene() -> PackedScene:
	return GlobalRegistry.loadSceneCached(getMeshPath())
