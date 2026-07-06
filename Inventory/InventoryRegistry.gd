extends Node
class_name InventoryRegistry

# Contains ALL of the inventories

var inventories:Dictionary[int, WeakRef] = {}

var lastUniqueID:int = 0

func _ready():
	GI.inventoryRegistry = self

func inventoryOnChange(_invChange:InventoryChange):
	if(!Network.isServerNotSingleplayer()):
		return
	
	var theChangeType := _invChange.getType()
	if(theChangeType == InventoryChange.ITEM_ADDED):
		var theItem := _invChange.addedGetItem()
		Network.rpcClients(invChangeAddItem_RPC.bind(_invChange.getInvUID(), theItem.id, theItem.saveNetworkData().getBytesCompressedSimple()))
	elif(theChangeType == InventoryChange.ITEM_REMOVED):
		var theItem := _invChange.removedGetItem()
		Network.rpcClients(invChangeRemoveItem_RPC.bind(_invChange.getInvUID(), theItem.uniqueID))
	elif(theChangeType == InventoryChange.ITEM_EQUIPPED):
		var theItem := _invChange.equippedGetItem()
		var theSlot := _invChange.getSlot()
		Network.rpcClients(invChangeEquipItem_RPC.bind(_invChange.getInvUID(), theSlot, theItem.id, theItem.saveNetworkData().getBytesCompressedSimple()))
	elif(theChangeType == InventoryChange.ITEM_UNEQUIPPED):
		var theSlot := _invChange.getSlot()
		Network.rpcClients(invChangeUnequipItem_RPC.bind(_invChange.getInvUID(), theSlot))
	elif(theChangeType == InventoryChange.ITEM_OPTION_CHANGED):
		var theItem := _invChange.optionChangedGetPart()
		var theOptionID := _invChange.optionChangedGetOptionID()
		var theValue = _invChange.optionChangedGetValue()
		Network.rpcClients(invChangeItemOption_RPC.bind(_invChange.getInvUID(), theItem.uniqueID, theOptionID, theValue))
		
@rpc("authority", "call_remote", "reliable")
func invChangeItemOption_RPC(_invUID:int, _itemUID:int, _optionID:String, _value:Variant):
	var theInv := findInventory(_invUID)
	if(!theInv):
		Log.Printerr("Couldn't find an inventory with UID: "+str(_invUID))
		return
	var newItem:ItemBase = theInv.findItemByUniqueID(_itemUID)
	if(!newItem):
		Log.Printerr("Couldn't find an item with unique ID: "+str(_itemUID))
		return
	newItem.setOptionValue(_optionID, _value)

@rpc("authority", "call_remote", "reliable")
func invChangeEquipItem_RPC(_invUID:int, _slot:int, _itemID:String, _bytes:PackedByteArray):
	var theInv := findInventory(_invUID)
	if(!theInv):
		Log.Printerr("Couldn't find an inventory with UID: "+str(_invUID))
		return
	var newItem:ItemBase = GlobalRegistry.createItem(_itemID, false)
	if(!newItem):
		Log.Printerr("Couldn't make an item with ID: "+str(_itemID))
		return
	newItem.loadNetworkData(Bins.readCompressedSimple(_bytes))
	theInv.equipItem(newItem, _slot)
	
@rpc("authority", "call_remote", "reliable")
func invChangeUnequipItem_RPC(_invUID:int, _slot:int):
	var theInv := findInventory(_invUID)
	if(!theInv):
		Log.Printerr("Couldn't find an inventory with UID: "+str(_invUID))
		return
	theInv.clearSlot(_slot)

@rpc("authority", "call_remote", "reliable")
func invChangeAddItem_RPC(_invUID:int, _itemID:String, _bytes:PackedByteArray):
	var theInv := findInventory(_invUID)
	if(!theInv):
		Log.Printerr("Couldn't find an inventory with UID: "+str(_invUID))
		return
	var newItem:ItemBase = GlobalRegistry.createItem(_itemID, false)
	if(!newItem):
		Log.Printerr("Couldn't make an item with ID: "+str(_itemID))
		return
	newItem.loadNetworkData(Bins.readCompressedSimple(_bytes))
	theInv.addItem(newItem)

@rpc("authority", "call_remote", "reliable")
func invChangeRemoveItem_RPC(_invUID:int, _itemUID:int):
	var theInv := findInventory(_invUID)
	if(!theInv):
		Log.Printerr("Couldn't find an inventory with UID: "+str(_invUID))
		return
	var theItem := theInv.findItemByUniqueID(_itemUID)
	if(!theItem):
		Log.Printerr("Couldn't find an item with UID: "+str(_itemUID))
		return
	theItem.removeSelf()

func registerNetworkInventory(_inventory:Inventory, _uid:int, _owner = null):
	if(_inventory.uniqueID >= 0):
		assert(false, "UniqueID is not valid!")
		return
	if(_uid < 0):
		assert(false, "UniqueID is not valid!")
		return
	_inventory.uniqueID = _uid
	inventories[_uid] = weakref(_inventory)
	_inventory.onChange.connect(inventoryOnChange)

func registerInventory(_inventory:Inventory, _owner = null):
	if(Network.isClient()):
		return
	if(_inventory.uniqueID >= 0):
		assert(false, "Trying to register an inventory that was already registered before!")
		return
	_inventory.uniqueID = getNewUniqueID()
	inventories[_inventory.uniqueID] = weakref(_inventory)
	_inventory.onChange.connect(inventoryOnChange)

func unregisterInventory(_inventory:Inventory):
	if(_inventory.uniqueID < 0):
		assert(false, "Trying to un-register an inventory that was never registered!")
		return
	if(!inventories.has(_inventory.uniqueID)):
		assert(false, "Inventory reference not found in the registry!")
		return
	inventories.erase(_inventory.uniqueID)
	_inventory.uniqueID = -2
	_inventory.onChange.disconnect(inventoryOnChange)

func findInventory(_uid:int) -> Inventory:
	if(!inventories.has(_uid)):
		return null
	var theInv:Inventory = inventories[_uid].get_ref()
	if(!theInv):
		inventories.erase(_uid)
		assert(false, "Found a leaked inventory!")
	return theInv

# Call this occasionally?
func checkInventoryRefs():
	var toRem:Array[int] = []
	for uid in inventories:
		var theRef := inventories[uid]
		if(!theRef.get_ref()):
			toRem.append(uid)
	for theRemovedUID in toRem:
		inventories.erase(theRemovedUID)

#func askUseItem(_item:ItemBase, _action:String, _args:Array):
	#pass
#
#@rpc("any_peer", "call_remote", "reliable")
#func askUseItem_SERVERRPC(_invUID:int, _itemSlot:int, _itemUID:int, _action:String, _args:Array):
	#pass

#func askEquipItem(_character:BaseCharacter, _item:ItemBase, _slot:int):
	#pass
#
#func askUnequipSlot(_character:BaseCharacter, _slot:int):
	#pass

func askDoActionOnItem(_item:ItemBase, _id:String, _args:Array = []):
	if(Network.isServer()):
		_item.tryDoActionSelf(_id, _args)
	else:
		askDoActionOnItem_SERVERRPC.rpc_id(1, _item.getInventory().uniqueID, _item.uniqueID, _id, _args)

@rpc("any_peer", "call_remote", "reliable")
func askDoActionOnItem_SERVERRPC(_invUID:int, _itemUID:int, _id:String, _args:Array):
	var theInv := findInventory(_invUID)
	if(!theInv):
		return
	var theItem := theInv.findItemByUniqueID(_itemUID)
	if(!theItem):
		return
	var theActions := theItem.getActionsFinal()
	for theEntry in theActions:
		if(theEntry[3] == _id && theEntry[4] == _args):
			theItem.tryDoActionSelf(theEntry[3], theEntry[4])
			return

func askTest(_inventory:Inventory):
	if(Network.isServer()):
		askTest_SERVERRPC(_inventory.uniqueID)
	else:
		askTest_SERVERRPC.rpc_id(1, _inventory.uniqueID)

@rpc("any_peer", "call_remote", "reliable")
func askTest_SERVERRPC(_uid:int):
	var theInv:Inventory = findInventory(_uid)
	if(!theInv):
		return
	if(true): # Disabled
		return
	#theInv.setEquippedItem(InventorySlot.Mouth, GlobalRegistry.createItem("BallGag"))
	#theInv.addItem(GlobalRegistry.createItem("BallGag"))
	var theChar := theInv.getChar()
	if(theChar):
		var theCharID:String = theChar.getID()
		var thePawn:CharacterPawn = GM.pawnRegistry.getPawn(theCharID)
		if(thePawn):
			spawnItem(thePawn.global_position, GlobalRegistry.createItem("BallGag"))

#func createInventory(_uid:int=-1) -> InventoryRef:
	#if(_uid < 0):
		#_uid = getNewUniqueID()
	#
	#var newInv:Inventory = Inventory.new()
	#newInv.uniqueID = _uid
	#inventories[_uid] = newInv
	#
	#if(Network.isServerNotSingleplayer()):
		#Network.rpcClients(createInventory_RPC.bind(_uid))
	#
	#var newRef:InventoryRef = InventoryRef.new()
	#newRef.uniqueID = _uid
	#return newRef
#
#@rpc("authority", "call_remote", "reliable")
#func createInventory_RPC(_uid:int):
	#createInventory(_uid)
#
#func deleteInventory(_uid:int) -> bool:
	#if(!inventories.has(_uid)):
		#return false
	#inventories.erase(_uid)
	#
	#if(Network.isServerNotSingleplayer()):
		#Network.rpcClients(deleteInventory_RPC.bind(_uid))
	#return true
#
#@rpc("authority", "call_remote", "reliable")
#func deleteInventory_RPC(_uid:int):
	#deleteInventory(_uid)
#
#func getInventoryByID(_uid:int) -> Inventory:
	#if(!inventories.has(_uid)):
		#return null
	#return inventories[_uid]

func getNewUniqueID() -> int:
	while(inventories.has(lastUniqueID)):
		lastUniqueID += 1
	return lastUniqueID

func spawnItem(_pos:Vector3, _item:ItemBase):
	if(!Network.isServer()):
		return
	var theItem:Node3D = preload("res://Inventory/Util/dropped_item.tscn").instantiate()
	GM.main.add_child(theItem, true)
	theItem.global_position = _pos
	
	GM.netNodes.makeNodeNetworked(theItem)
	theItem.inventory.addItem(_item)

func saveNetworkData() -> Bins:
	var theAr:Array = [
		Bins.I32, lastUniqueID,
		#Bins.I32, inventories.size(),
	]
	#for uid in inventories:
		#theAr.append_array([
			#Bins.I32, uid,
			#Bins.BINS, inventories[uid].saveNetworkData(),
		#])
	return Bins.saveStartEnd(theAr)

func loadNetworkData(_data:Bins):
	_data.loadStart()
	lastUniqueID = _data.readI32()
	#var invAmount:int = _data.readI32()
	
	#for _i in range(invAmount):
		#var uid:int = _data.readI32()
		#var theInvData := _data.readBins()
		#
		#var newInv:Inventory = Inventory.new()
		#newInv.uniqueID = uid
		#inventories[uid] = newInv
		#newInv.loadNetworkData(theInvData)
		
	_data.endLoad()

func saveData() -> Dictionary:
	#var invDatas:Dictionary = {}
	#for uid in inventories:
	#	invDatas[uid] = inventories[uid].saveData()
	
	return {
		lastUniqueID = lastUniqueID,
		#inventories = invDatas,
	}

func loadData(_data:Dictionary):
	lastUniqueID = SAVE.loadVar(_data, "lastUniqueID", -1)
	
	#inventories.clear()
	#var invData:Dictionary = SAVE.loadVar(_data, "inventories", {})
	#for uid in invData:
		#var theData:Dictionary = invData[uid]
		#
		#var newInv:Inventory = Inventory.new()
		#newInv.uniqueID = uid
		#inventories[uid] = newInv
		#newInv.loadData(theData)
