extends PropHandlerBase

@onready var sit_spawner: AnimSceneSpawner = $SitSpawner
@onready var pawn_interactable: PawnInteractable = %PawnInteractable
@onready var stand_spot: Marker3D = %StandSpot

@export var stocks:Node3D

func _ready():
	pawn_interactable.setTarget(self)
	if(GM.world):
		GM.world.addStocks.call_deferred(self)

func getInteractCategory(_pawn:CharacterPawn) -> InteractCategory:
	var category := InteractCategory.new()
	
	category.categoryName = "Stocks"
	category.interactEntries.append(
		InteractEntryText.create("Stocks can be used for sex!")
	)
	category.interactEntries.append(
		InteractEntryDo.create("SitProp", [
			"dom", "Lock yourself",
		])
	)
	
	category.interactEntries.append(InteractEntryDo.create("Generic", ["pose"]))
	category.interactEntries.append(InteractEntryDo.create("Generic", ["use"]))
	category.interactEntries.append(InteractEntryDo.create("Generic", ["unlock"]))
	
	#for leashedPawn in _pawn.getLeashedPawns():
		#category.interactEntries.append(InteractEntryDo.create("SitPropLeashed", ["dom", "Lock $$$", leashedPawn.getCharID()]))
	category.addSitPropLeashedActions(_pawn, "dom", "Lock $$$")
	
	return category

func getQuickInteractActions(_pawn:CharacterPawn) -> Array[InteractEntryDo]:
	var result:Array[InteractEntryDo] = []
	
	#result.append(
		#InteractEntryDo.create("SitProp", [
			#"dom", "Lock yourself",
		#])
	#)
	result.append(InteractEntryDo.create("Interact", ["Stocks"]))
	
	return result

func canUseSitterSlot(_slot:String) -> bool:
	if(_slot == "dom"):
		if(GM.sitManager.getSpotOfProp(stocks)):
			return false
	return true

func getSitterSlot(_slot:String) -> CharacterPawn:
	return sit_spawner.getSitter(_slot)

func setSitter(_slot:String, _pawn:CharacterPawn) -> bool:
	if(!_pawn):
		sit_spawner.unsitToStandSpot("dom", stand_spot)
		sit_spawner.despawn()
		return true
	if(!sit_spawner.isSpawned()):
		sit_spawner.spawn()
		sit_spawner.setProp("stocks", stocks)
	sit_spawner.setSitter(_slot, _pawn)
	#sit_spawner.despawnIfNoSitters()
	return true

func getGenericActionName(_id:String, _args:Array, _context:PawnActionContext, _action:PawnActionBase) -> String:
	if(_id == "pose"):
		return "Change pose"
	if(_id == "use"):
		return "Use in stocks"
	if(_id == "unlock"):
		return "Unlock"
	
	return "ERROR!"

func canDoGenericAction(_id:String, _args:Array, _context:PawnActionContext, _action:PawnActionBase) -> bool:
	if(_id == "pose"):
		# Has bound arms check or something
		if(!sit_spawner.getSitter("dom")):
			return false
		return true
	if(_id == "unlock"):
		# Has bound arms check or something
		if(sit_spawner.getSitter("dom") && sit_spawner.getSitter("dom") != _context.pawn):
			return true
		return false
	if(_id == "use"):
		#TODO: Can start sex check or something. _context.pawn can't be sitting or be in sex
		if(sit_spawner.getSitter("dom") && sit_spawner.getSitter("dom") != _context.pawn):
			return true
		return false

	return true

func doGenericAction(_id:String, _args:Array, _context:PawnActionContext, _action:PawnActionBase) -> bool:
	if(_id == "pose"):
		if(sit_spawner.isSpawned()):
			if(sit_spawner.getScene().getState() == "standing"):
				sit_spawner.getScene().playStateGlobal("bent")
			else:
				sit_spawner.getScene().playStateGlobal("standing")
	if(_id == "use"):
		var newSex := SexStartConf.new()
		newSex.sexType = SexType.InStocks
		newSex.addRole("dom", _context.pawn.getCharID(), SexRole.Dom)
		newSex.addRole("sub", sit_spawner.getSitter("dom").getCharID(), SexRole.Sub)
		newSex.pos = stocks.global_position
		newSex.ang = stocks.global_rotation
		newSex.addProp("stocks", stocks)
		GM.sexManager.startSex(newSex)
		return true
	if(_id == "unlock"):
		setSitter("dom", null)
		return true

	return true

func getAllSitterSlots() -> Array[String]:
	return ["dom"]

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.BINS, sit_spawner.saveNetworkData(),
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	sit_spawner.loadNetworkData(_data.readBins())
	_data.endLoad()

func saveData() -> Dictionary:
	return {
		sit = sit_spawner.saveData(),
	}

func loadData(_data:Dictionary):
	sit_spawner.loadData(SAVE.loadVar(_data, "sit", {}))

func _on_sit_spawner_on_pawn_switch(_id: Variant, _pawn: Variant) -> void:
	sit_spawner.despawnIfNoSitters()

func getSexStartInfo(_pawns:Array[CharacterPawn]) -> Dictionary:
	if(_pawns.size() != 2):
		return {}
	return createSexStartInfo(
		SexType.InStocks, {dom=_pawns[0], sub=_pawns[1]}, global_position, global_rotation
	)
