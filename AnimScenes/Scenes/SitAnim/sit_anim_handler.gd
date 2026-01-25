extends PropHandlerBase

@export var categoryName:String = "Chair"

@onready var sit_spawner: AnimSceneSpawner = $SitSpawner
@onready var pawn_interactable: PawnInteractable = %PawnInteractable
@onready var stand_spot: Marker3D = %StandSpot

func _ready():
	pawn_interactable.setTarget(self)

func getInteractCategory(_pawn:CharacterPawn) -> InteractCategory:
	var category := InteractCategory.new()
	
	category.categoryName = categoryName
	category.interactEntries.append(InteractEntryDo.create("SitProp", ["dom",]))
	
	category.addSitPropLeashedActions(_pawn, "dom", "Make $$$ sit")
	
	return category

func getQuickInteractActions(_pawn:CharacterPawn) -> Array[InteractEntryDo]:
	var result:Array[InteractEntryDo] = []
	
	result.append(InteractEntryDo.create("SitProp", ["dom",]))
	
	return result

func getSitterSlot(_slot:String) -> CharacterPawn:
	return sit_spawner.getSitter(_slot)

func setSitter(_slot:String, _pawn:CharacterPawn) -> bool:
	if(!_pawn):
		sit_spawner.unsitToStandSpot(_slot, stand_spot)
		sit_spawner.despawn()
		return true
	if(!sit_spawner.isSpawned()):
		sit_spawner.spawn()
		#sit_spawner.setProp("stocks", stocks)
	sit_spawner.setSitter(_slot, _pawn)
	#sit_spawner.despawnIfNoSitters()
	return true
	
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
