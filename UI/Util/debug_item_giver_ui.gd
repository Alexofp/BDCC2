extends PanelContainer

var dollUser
var giverNode:WeakRef

@onready var item_list: ItemList = %ItemList
@onready var inv_entries_list: VBoxContainer = %SlotsList

var selectorVar := preload("res://UI/VarList/Vars/dropdown_var.tscn")
var entryBySlot:Dictionary = {}

var itemIDs:Array[String] = []

func _enter_tree() -> void:
	UIHandler.addUI(self)

func _exit_tree() -> void:
	UIHandler.removeUI(self)

func _on_close_button_pressed() -> void:
	queue_free()

func _ready() -> void:
	for theItemID in GlobalRegistry.getItemRefs():
		item_list.add_item(theItemID)
		itemIDs.append(theItemID)

	Util.delete_children(inv_entries_list)
	for inventorySlot in InventorySlot.getAll():
		var invSlotName:String = InventorySlot.getName(inventorySlot)
		
		var newSelector = selectorVar.instantiate()
		inv_entries_list.add_child(newSelector)
		newSelector.setData({
			name = invSlotName,
			values = [],
		})
		newSelector.onValueChange.connect(onNewItemIDSelected.bind(inventorySlot))
		
		entryBySlot[inventorySlot] = newSelector
	
	updateInventory()
	
func _on_give_button_pressed() -> void:
	if(item_list.get_selected_items().is_empty()):
		return
	var theSelectedIndx:int = item_list.get_selected_items()[0]
	
	if(theSelectedIndx < 0 || theSelectedIndx >= itemIDs.size()):
		return
	var theItemID:String = itemIDs[theSelectedIndx]
	
	if(giverNode):
		if(!giverNode || !giverNode.get_ref()):
			Log.Printerr("Debug item giver UI needs to be connected to an item giver!")
			return
		GM.netNodes.sendServerEvent(giverNode.get_ref(), "giveItem", [theItemID, dollUser])
	else:
		var theDoll:DollController= GI.getNodeByUniqueID(dollUser)
		var theChar:=theDoll.getCharacter()
		GM.game.askDebugGiveItem(theChar, theItemID)
	
func onNewItemIDSelected(_id, _value:String, _slot:int):
	if(giverNode):
		if(!giverNode || !giverNode.get_ref()):
			Log.Printerr("Debug item giver UI needs to be connected to an item giver!")
			return
		GM.netNodes.sendServerEvent(giverNode.get_ref(), "equipItem", [_slot, _value, dollUser])
	else:
		var theDoll:DollController= GI.getNodeByUniqueID(dollUser)
		var theChar:=theDoll.getCharacter()
		GM.game.askDebugEquipItem(theChar, _slot, _value)
	#GM.characterRegistry.askCharacterPartChange(theChar, BaseCharacter.GENERIC_CLOTHING, _slot, _value, {})
	#inventory.setEquippedItem(_slot, GlobalRegistry.createItem(_value) if _value != "" else null)
	
func updateInventory():
	var theDoll:DollController= GI.getNodeByUniqueID(dollUser)
	if(!theDoll):
		return
	var theChar:=theDoll.getCharacter()
	if(!theChar):
		return
	var inventory:=theChar.getInventory()
	
	for inventorySlot in InventorySlot.getAll():
		var theSelector = entryBySlot[inventorySlot]
		
		var possibleIDs:Array = []
		possibleIDs.append(["", "Nothing"])
		for itemID in GlobalRegistry.getItemRefs():
			var theItemRef:ItemBase = GlobalRegistry.getItemRef(itemID)
			if(inventorySlot in theItemRef.getSlotsToEquipTo()):
				possibleIDs.append([itemID, theItemRef.getName()])
		
		theSelector.setData({
			value = inventory.getEquippedItem(inventorySlot).id if inventory && inventory.hasSlotEquipped(inventorySlot) else "",
			values = possibleIDs,
		})
