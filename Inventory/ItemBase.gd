extends RefWithOptions
class_name ItemBase

var id:String = "error"
var currentInventory:Inventory = null

func _init():
	super._init()

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

func getMeshStructure(_baseCharacter:BaseCharacter) -> Dictionary:
	return {}

func getMeshPath() -> String:
	return "res://Mesh/Clothing/SimpleTshirt/t_shirt.tscn"

func getMeshScene() -> PackedScene:
	return GlobalRegistry.loadSceneCached(getMeshPath())

func getCharacter() -> BaseCharacter:
	if(currentInventory == null):
		return null
	return currentInventory.getCharacter()

func updateCharacterPartTags():
	var theChar = getCharacter()
	if(theChar != null):
		theChar.tellOnPartTagsNeedUpdate()
