extends VBoxContainer

@onready var inv_entries_list: VBoxContainer = %InvEntriesList
var selectorVar := preload("res://UI/VarList/Vars/dropdown_var.tscn")

var entryBySlot:Dictionary = {}

func _ready() -> void:
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

var inventory:Inventory

func setCharacter(_char:BaseCharacter):
	setInventory(_char.getInventory() if _char else null)

func setInventory(_inv:Inventory):
	inventory = _inv
	updateInventory()

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
	inventory.setEquippedItem(_slot, GlobalRegistry.createItem(_value) if _value != "" else null)
