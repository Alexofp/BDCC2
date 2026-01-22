extends PropHandlerBase

@onready var sit_spawner_left: AnimSceneSpawner = $SitSpawnerLeft
@onready var sit_spawner_right: AnimSceneSpawner = $SitSpawnerRight
@onready var sit_spawner_cuddle: AnimSceneSpawner = $SitSpawnerCuddle
@onready var pawn_interactable: PawnInteractable = %PawnInteractable

func _ready():
	pawn_interactable.setTarget(self)

func getInteractCategory(_pawn:CharacterPawn) -> InteractCategory:
	var category := InteractCategory.new()
	
	category.categoryName = "Bench"
	#category.interactEntries.append(
		#InteractEntryDo.create("SitProp", [
			#"left", "Sit (left)",
		#]))
	category.interactEntries.append_array(getQuickInteractActions(_pawn))
	
	category.addSitPropLeashedActions(_pawn, "left", "Make $$$ sit (left)")
	category.addSitPropLeashedActions(_pawn, "right", "Make $$$ sit (right)")
	
	return category

func getQuickInteractActions(_pawn:CharacterPawn) -> Array[InteractEntryDo]:
	var result:Array[InteractEntryDo] = []
	
	result.append(InteractEntryDo.create("SitProp", ["left", "Sit (left)"]))
	result.append(InteractEntryDo.create("SitProp", ["right", "Sit (right)"]))
	
	result.append(InteractEntryDo.create("Generic", ["cuddle"]))
	result.append(InteractEntryDo.create("Generic", ["stopCuddle"]))
	
	return result

func canUseSitterSlot(_slot:String) -> bool:
	if(sit_spawner_cuddle.isSpawned()):
		return false
	return true

func getGenericActionName(_id:String, _args:Array, _context:PawnActionContext, _action:PawnActionBase) -> String:
	if(_id == "cuddle"):
		return "Cuddle"
	if(_id == "stopCuddle"):
		return "Stop cuddling"
	return "ERROR!"

func canDoGenericAction(_id:String, _args:Array, _context:PawnActionContext, _action:PawnActionBase) -> bool:
	if(_id == "cuddle"):
		var leftSitter := getSitterSlot("left")
		var rightSitter := getSitterSlot("right")
		
		if(leftSitter && rightSitter && (leftSitter == _context.pawn || rightSitter == _context.pawn)):
			return true
		return false
	if(_id == "stopCuddle"):
		var leftSitter:CharacterPawn = sit_spawner_cuddle.getSitter("dom")
		var rightSitter:CharacterPawn = sit_spawner_cuddle.getSitter("sub")
		
		if(leftSitter && rightSitter && (leftSitter == _context.pawn || rightSitter == _context.pawn)):
			return true
		return false
	
	return true

func doGenericAction(_id:String, _args:Array, _context:PawnActionContext, _action:PawnActionBase) -> bool:
	if(_id == "cuddle"):
		var leftSitter := getSitterSlot("left")
		var rightSitter := getSitterSlot("right")
		sit_spawner_left.despawn()
		sit_spawner_right.despawn()
		sit_spawner_cuddle.spawn()
		sit_spawner_cuddle.setSitter("dom", leftSitter)
		sit_spawner_cuddle.setSitter("sub", rightSitter)
		return true
	if(_id == "stopCuddle"):
		var leftSitter:CharacterPawn = sit_spawner_cuddle.getSitter("dom")
		var rightSitter:CharacterPawn = sit_spawner_cuddle.getSitter("sub")
		sit_spawner_cuddle.despawn()
		sit_spawner_left.spawn()
		sit_spawner_right.spawn()
		sit_spawner_left.setSitter("dom", leftSitter)
		sit_spawner_right.setSitter("dom", rightSitter)
		
	return true

func getSitterSlot(_slot:String) -> CharacterPawn:
	if(_slot == "left"):
		return sit_spawner_left.getSitter("dom")
	if(_slot == "right"):
		return sit_spawner_right.getSitter("dom")
	#return sit_spawner.getSitter(_slot)
	return null

func setSitter(_slot:String, _pawn:CharacterPawn) -> bool:
	if(_slot == "left"):
		if(!_pawn):
			sit_spawner_left.despawn()
			return true
		if(!sit_spawner_left.isSpawned()):
			sit_spawner_left.spawn()
		sit_spawner_left.setSitter("dom", _pawn)
	if(_slot == "right"):
		if(!_pawn):
			sit_spawner_right.despawn()
			return true
		if(!sit_spawner_right.isSpawned()):
			sit_spawner_right.spawn()
		sit_spawner_right.setSitter("dom", _pawn)
	return true

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.BINS, sit_spawner_left.saveNetworkData(),
		Bins.BINS, sit_spawner_right.saveNetworkData(),
		Bins.BINS, sit_spawner_cuddle.saveNetworkData(),
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	sit_spawner_left.loadNetworkData(_data.readBins())
	sit_spawner_right.loadNetworkData(_data.readBins())
	sit_spawner_cuddle.loadNetworkData(_data.readBins())
	_data.endLoad()
	
func saveData() -> Dictionary:
	return {
		left = sit_spawner_left.saveData(),
		right = sit_spawner_right.saveData(),
		cuddle = sit_spawner_cuddle.saveData(),
	}

func loadData(_data:Dictionary):
	sit_spawner_left.loadData(SAVE.loadVar(_data, "left", {}))
	sit_spawner_right.loadData(SAVE.loadVar(_data, "right", {}))
	sit_spawner_cuddle.loadData(SAVE.loadVar(_data, "cuddle", {}))
