extends Node3D

@onready var sit_spawner: AnimSceneSpawner = $SitSpawner
@onready var interactable: Interactable = %Interactable
@onready var pawn_interactable: PawnInteractable = %PawnInteractable

@export var stocks:Node3D

func _ready():
	interactable.dynamicActionsFunc = getActions
	
	pawn_interactable.setTarget(self)

func getInteractCategory(_pawn:CharacterPawn) -> InteractCategory:
	var category := InteractCategory.new()
	
	category.categoryName = "Stocks"
	category.interactEntries.append(
		InteractEntryText.create("STOCKSSS")
	)
	category.interactEntries.append(
		InteractEntryDo.create("SitProp", [
			"dom", "Lock yourself",
		])
	)
	
	return category

func getQuickInteractActions(_pawn:CharacterPawn) -> Array[InteractEntryDo]:
	var result:Array[InteractEntryDo] = []
	
	result.append(
		InteractEntryDo.create("SitProp", [
			"dom", "Lock yourself",
		])
	)
	result.append(
		InteractEntryDo.create("Generic", [
			"test",
		])
	)
	
	return result

func getSitterSlot(_slot:String) -> CharacterPawn:
	return sit_spawner.getSitter(_slot)

func setSitter(_slot:String, _pawn:CharacterPawn) -> bool:
	if(!_pawn):
		sit_spawner.despawn()
		return true
	if(!sit_spawner.isSpawned()):
		sit_spawner.spawn()
		sit_spawner.setProp("stocks", stocks)
	sit_spawner.setSitter(_slot, _pawn)
	#sit_spawner.despawnIfNoSitters()
	return true

func getActions(_interactor:Interactor, _user:DollController) -> Array[InteractAction]:
	if(!_user):
		return []
	var thePawn:CharacterPawn = _user.getPawn()
	if(!thePawn):
		return []

	var result:Array[InteractAction] = []
	
	if(sit_spawner.getSitter("dom") == thePawn):
		result.append(InteractAction.create(
			"unsit", "Get up",
		))
	if(sit_spawner.getSitter("dom")):
		result.append(InteractAction.create(
			"pose", "Switch pose",
		))
		if(sit_spawner.getSitter("dom") != thePawn):
			result.append(InteractAction.create(
				"use", "Use in stocks!",
			))
	
	if(!sit_spawner.hasSitter("dom") && thePawn.canSit()):
		result.append(InteractAction.create(
			"sit", "Sit",
		))
	
	return result

func sitPawn(_pawn:CharacterPawn):
	if(!sit_spawner.isSpawned()):
		sit_spawner.spawn()
	sit_spawner.setSitter("dom", _pawn)
	sit_spawner.setProp("stocks", stocks)

func _on_interactable_on_interact(user: DollController, action: InteractAction) -> void:
	if(action.id == "sit"):
		sitPawn(user.getPawn())
		#if(!sit_spawner.isSpawned()):
		#	sit_spawner.spawn()
		#sit_spawner.setSitter("dom", user.getPawn())
		#sit_spawner.setProp("stocks", stocks)
		
		#GM.leashSystem.connectLeash(
			#LeashPointConnection.createLeashpoint($LeashPoint),
			#LeashPointConnection.createPawnLeashpoint(user.getPawn().getCharID(), "leashholder.R")
		#)
	if(action.id == "unsit"):
		if(sit_spawner.getSitter("dom") == user.getPawn()):
			sit_spawner.despawn()
	if(action.id == "pose"):
		if(sit_spawner.isSpawned()):
			if(sit_spawner.getScene().getState() == "standing"):
				sit_spawner.getScene().playStateGlobal("bent")
			else:
				sit_spawner.getScene().playStateGlobal("standing")
	if(action.id == "use"):
		var newSex := SexStartConf.new()
		newSex.sexType = SexType.InStocks
		newSex.addRole("dom", user.getCharacter().getID(), SexRole.Dom)
		newSex.addRole("sub", sit_spawner.getSitter("dom").getCharID(), SexRole.Sub)
		newSex.pos = stocks.global_position
		newSex.ang = stocks.global_rotation
		newSex.addProp("stocks", stocks)
		GM.sexManager.startSex(newSex)
	
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
