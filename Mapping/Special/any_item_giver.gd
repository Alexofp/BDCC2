extends PropHandlerBase

@onready var pawn_interactable: PawnInteractable = %PawnInteractable

func _ready() -> void:
	pawn_interactable.setTarget(self)

func getInteractCategory(_pawn:CharacterPawn) -> InteractCategory:
	var category := InteractCategory.new()
	
	category.categoryName = "Debug item giver"
	category.interactEntries.append(InteractEntryDo.create("Generic", ["openUI"]))
	#category.interactEntries.append_array(getQuickInteractActions(_pawn))
	
	return category

func getQuickInteractActions(_pawn:CharacterPawn) -> Array[InteractEntryDo]:
	var result:Array[InteractEntryDo] = []
	result.append(InteractEntryDo.create("Generic", ["openUI"]))
	#result.append(InteractEntryDo.create("SitProp", ["dom",]))
	return result

func getGenericActionName(_id:String, _args:Array, _context:PawnActionContext, _action:PawnActionBase) -> String:
	if(_id == "openUI"):
		return "Get any item menu"
	return "ERROR!"

func canDoGenericAction(_id:String, _args:Array, _context:PawnActionContext, _action:PawnActionBase) -> bool:
	return true

func doGenericAction(_id:String, _args:Array, _context:PawnActionContext, _action:PawnActionBase) -> bool:
	if(_id == "openUI"):
		var theDoll := _context.pawn.getDoll()
		if(!theDoll):
			return false
		var nid := theDoll.getNetworkPlayerID()
		if(nid < 0):
			return false
		GM.netNodes.sendGlobalEvent(self, "openUI", [nid, GI.getUniqueIDOf(theDoll)])
		# get player net id from the doll controller
		# send a rpc (or a local call if we are the server) to open the menu. RPC how?
		# That rpc contains this object?
		# The player presses a button to get some item
		# This sends an RPC to a server (or a local call) to this object
		# This object checks if the player is 'allowed' to get an item and gives them if they do
		# This (automatically) syncs everything
		return true
	return true

func handleGlobalEvent(_id:String, _args:Array):
	#Log.Print("GLOBAL EVENT: "+_id)
	if(_id == "openUI" && _args.size() >= 2):
		if(Network.getMultiplayerID() == _args[0]):
			#Log.Print("I SHOULD OPEN THE UI!")
			
			var theGiverUI = load("res://UI/Util/debug_item_giver_ui.tscn").instantiate()
			theGiverUI.giverNode = weakref(self)
			theGiverUI.dollUser = _args[1]
			GM.main.addUINode(theGiverUI)

#func _process(_delta: float) -> void:
	#if(!UIHandler.hasAnyUIVisible() && Input.is_action_just_pressed("debug_item_giver")):
		#var theGiverUI = load("res://UI/Util/debug_item_giver_ui.tscn").instantiate()
		#theGiverUI.giverNode = weakref(self)
		#theGiverUI.dollUser = GI.getUniqueIDOf(GM.pcDoll)
		#GM.main.addUINode(theGiverUI)

func handleServerEvent(_id:String, _args:Array):
	if(_id == "giveItem" && _args.size() >= 2):
		var _theItemID:String = _args[0]
		var theDoll:DollController = GI.getNodeByUniqueID(_args[1])
		
		if(!theDoll):
			return
		
		Log.Print("GIVING ITEM "+str(_theItemID)+" TO NPC "+str(theDoll.getCharacter().getID()))
		theDoll.getCharacter().getInventory().addItem(GlobalRegistry.createItem(_theItemID))
	
	if(_id == "equipItem" && _args.size() >= 3):
		var _theSlot:int = _args[0]
		var _theItemID:String = _args[1]
		var theDoll:DollController = GI.getNodeByUniqueID(_args[2])
		
		if(!theDoll):
			return
		
		Log.Print("EQUIPPING ITEM "+str(_theItemID)+" TO NPC "+str(theDoll.getCharacter().getID()))
		theDoll.getCharacter().getInventory().setEquippedItem(_theSlot, GlobalRegistry.createItem(_theItemID) if !_theItemID.is_empty() else null)
