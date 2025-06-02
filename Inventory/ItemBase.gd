extends GenericPart
class_name ItemBase

#var id:String = ""
var uniqueID:int = 0

var invRef:WeakRef

func getName() -> String:
	return id+":"+str(uniqueID)

func getSlotsToEquipTo() -> Array[int]:
	var theSlot:int = getSlot()
	if(theSlot >= 0):
		return [theSlot]
	return []

func getSlot() -> int:
	return -1

func isEquipable() -> bool:
	return getSlot() >= 0

func getInventory() -> Inventory:
	if(!invRef):
		return null
	return invRef.get_ref()

func setInventory(_inv:Inventory):
	if(_inv == null):
		invRef = null
		return
	invRef = weakref(_inv)

func getCharacter() -> BaseCharacter:
	var theInv:Inventory = getInventory()
	if(theInv == null):
		return null
	return theInv.getCharacter()

func getClothingSelectorPaths() -> Array:
	return []
#
#func getScenePathForItemID(_itemID:String) -> String:
	#for clothingSelectorA in GlobalRegistry.getClothingSelectors():
		#var clothingSelector:ClothingSceneSelector = clothingSelectorA
		#
		##if(clothingSelector.)
	#return ""

func getScenePathForCharacter(_slot:int, _theChar:BaseCharacter) -> String:
	if(!_theChar):
		return ""
	for clothingSelectorA in GlobalRegistry.getClothingSelectors():
		var clothingSelector:ClothingSceneSelector = clothingSelectorA
		
		if(clothingSelector.itemID != id):
			continue
		
		for bodypartID in clothingSelector.sceneByBodypartID:
			if(_theChar.hasBodypartID(bodypartID)):
				return clothingSelector.sceneByBodypartID[bodypartID]
		
	return ""

func getScenePath(_slot:int) -> String:
	return getScenePathForCharacter(_slot, getCharacter())

func shouldHobbleLegs() -> bool:
	return false

func getSexHideTags() -> Dictionary:
	return {}

func saveNetworkData() -> Dictionary:
	return {}

func loadNetworkData(_data:Dictionary):
	pass
