extends VBoxContainer

@onready var inv_entries_list: VBoxContainer = %InvEntriesList
var selectorVar := preload("res://UI/VarList/Vars/dropdown_var.tscn")
const INVENTORY_ENTRY_UI = preload("res://Inventory/UI/inventory_entry_ui.tscn")
@onready var smart_button_grid: SmartButtonGrid = %SmartButtonGrid

@onready var desc_container: PanelContainer = %DescContainer
@onready var desc_rich_label: RichTextLabel = %DescRichLabel


var entryBySlot:Dictionary = {}

var inventory:Inventory
var selectedUID:int = -1
var invEntries:Array = []

func _ready() -> void:
	Util.delete_children(inv_entries_list)
	
	#for inventorySlot in InventorySlot.getAll():
		#var invSlotName:String = InventorySlot.getName(inventorySlot)
		#
		#var newSelector = selectorVar.instantiate()
		#inv_entries_list.add_child(newSelector)
		#newSelector.setData({
			#name = invSlotName,
			#values = [],
		#})
		#newSelector.onValueChange.connect(onNewItemIDSelected.bind(inventorySlot))
		#
		#entryBySlot[inventorySlot] = newSelector

func updateInventoryList():
	Util.delete_children(inv_entries_list)
	invEntries.clear()
	
	if(!inventory):
		return
	for slot in inventory.getEquippedItems():
		var theItem := inventory.getEquippedItem(slot)
		var newEntry := INVENTORY_ENTRY_UI.instantiate()
		inv_entries_list.add_child(newEntry)
		invEntries.append(newEntry)
		
		internal_processEntry(theItem, newEntry)
		newEntry.setPostFix("(Equipped)")
	
	for theItem in inventory.getItems():
		var newEntry := INVENTORY_ENTRY_UI.instantiate()
		inv_entries_list.add_child(newEntry)
		invEntries.append(newEntry)
		
		internal_processEntry(theItem, newEntry)
		newEntry.setPostFix("")
	
	updateInventoryListSelected()

func internal_processEntry(theItem:ItemBase, newEntry):
	var _isSelected:bool = theItem.uniqueID == selectedUID
	
	newEntry.setItem(theItem)
	newEntry.setSelected(_isSelected)
	newEntry.onSelected.connect(onEntryPressed)

func onEntryPressed(_uid:int):
	selectedUID = _uid
	updateInventoryListSelected()

func updateInventoryListSelected():
	if(!inventory):
		return
	var theItem:ItemBase = inventory.findItemByUniqueID(selectedUID) if selectedUID >= 0 else null
	if(theItem):
		desc_rich_label.text = theItem.getDescriptionFinal()
	else:
		desc_rich_label.text = ""
		
	for theEntry in invEntries:
		var _isSelected:bool = theEntry.itemUID == selectedUID
		theEntry.setSelected(_isSelected)
	
	smart_button_grid.clearButtons()
	if(selectedUID >= 0):
		#var theItem:ItemBase = inventory.findItemByUniqueID(selectedUID)
		if(!theItem):
			return
		var theActions := theItem.getActionsFinal()
		for theActionEntry in theActions:
			if(theActionEntry[0]):
				smart_button_grid.addButton(SmartGridButtonEntry.make(theActionEntry[1], theActionEntry[3], theActionEntry[4]))
			else:
				smart_button_grid.addButton(SmartGridButtonEntry.makeDisabled(theActionEntry[1]))
	
func setCharacter(_char:BaseCharacter):
	setInventory(_char.getInventory() if _char else null)

func setInventory(_inv:Inventory):
	if(inventory):
		inventory.onChange.disconnect(onInventoryChange)
	inventory = _inv
	if(inventory):
		inventory.onChange.connect(onInventoryChange)
	#updateInventory()
	updateInventoryList()

func onInventoryChange(_invChange:InventoryChange):
	updateInventoryList()

func updateInventory():
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

func onNewItemIDSelected(_id, _value:String, _slot:int):
	if(!inventory):
		return
	GM.characterRegistry.askCharacterPartChange(inventory.getChar(), BaseCharacter.GENERIC_CLOTHING, _slot, _value, {})
	#inventory.setEquippedItem(_slot, GlobalRegistry.createItem(_value) if _value != "" else null)

#func _on_test_button_pressed() -> void:
#	GM.inventoryRegistry.askTest(inventory)


func _on_test_button_pressed() -> void:
	GM.inventoryRegistry.askTest(inventory)

func _on_smart_button_grid_on_button_pressed(_buttonEntry: SmartGridButtonEntry) -> void:
	if(!inventory || selectedUID < 0):
		return
	var theItem := inventory.findItemByUniqueID(selectedUID)
	if(!theItem):
		return
	GM.inventoryRegistry.askDoActionOnItem(theItem, _buttonEntry.actionID, _buttonEntry.actionArgs)
