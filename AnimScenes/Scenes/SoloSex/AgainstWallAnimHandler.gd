extends PropHandlerBase

@export var categoryName:String = "Wall"

@onready var sit_spawner: AnimSceneSpawner = $SitSpawner
@onready var pawn_interactable: PawnInteractable = %PawnInteractable
@onready var stand_spot: Marker3D = %StandSpot

const POSES = [
	"backLegUp",
	"stripSearch",
]
const POSE_NAMES = [
	"Against wall leg up",
	"Strip search"
]

func _ready():
	pawn_interactable.setTarget(self)
	GM.world.addActiveLeaner.call_deferred(self)

func getInteractCategory(_pawn:CharacterPawn) -> InteractCategory:
	var category := InteractCategory.new()
	
	category.categoryName = categoryName
	category.interactEntries.append(InteractEntryDo.create("SitProp", ["dom"]))
	
	category.addSitPropLeashedActions(_pawn, "dom", "Make $$$ lean")
	
	for _i in POSES.size():
		#var poseID:String = POSES[_i]
		#var poseName:String = POSE_NAMES[_i]
		category.interactEntries.append(InteractEntryDo.create("Generic", ["poseSpecific", [_i]]))
	
	category.interactEntries.append(InteractEntryDo.create("Generic", ["sex"]))
	category.interactEntries.append(InteractEntryDo.create("Generic", ["forcesex"]))
	
	return category

func getQuickInteractActions(_pawn:CharacterPawn) -> Array[InteractEntryDo]:
	var result:Array[InteractEntryDo] = []
	
	result.append(InteractEntryDo.create("SitProp", ["dom",]))
	result.append(InteractEntryDo.create("Generic", ["posenext"]))
	
	return result

func getSitterSlot(_slot:String) -> CharacterPawn:
	return sit_spawner.getSitter(_slot)

func setSitter(_slot:String, _pawn:CharacterPawn) -> bool:
	if(!_pawn):
		sit_spawner.unsitToStandSpot(_slot, stand_spot)
		sit_spawner.despawn()
		if(Network.isServer()):
			queue_free()
		return true
	if(!sit_spawner.isSpawned()):
		sit_spawner.spawn()
		#sit_spawner.setProp("stocks", stocks)
	sit_spawner.setSitter(_slot, _pawn)
	#sit_spawner.despawnIfNoSitters()
	return true
	
func getGenericActionName(_id:String, _args:Array, _context:PawnActionContext, _action:PawnActionBase) -> String:
	if(_id == "posenext"):
		return "Change pose"
	if(_id == "sex"):
		return "Offer sex"
	if(_id == "forcesex"):
		return "Force sex"
	if(_id == "poseSpecific"):
		var _indx:int = _args[0] if _args.size() > 0 else 0
		if(_indx < 0 || _indx >= POSE_NAMES.size()):
			return "POSE: BAD!!"
		return "Pose: "+str(POSE_NAMES[_indx])
	
	return "ERROR!"

func canDoGenericAction(_id:String, _args:Array, _context:PawnActionContext, _action:PawnActionBase) -> bool:
	if(_id == "posenext"):
		if(sit_spawner.getSitter("dom") != _context.pawn):
			return false
		return true
	if(_id == "poseSpecific"):
		if(sit_spawner.getSitter("dom") != _context.pawn):
			return false
		return true
	if(_id == "sex"):
		if(GM.sitManager.isSitting(_context.pawn)):
			return false
		return true
	if(_id == "forcesex"):
		if(GM.sitManager.isSitting(_context.pawn)):
			return false
		return true
	return true

func doGenericAction(_id:String, _args:Array, _context:PawnActionContext, _action:PawnActionBase) -> bool:
	if(_id == "posenext"):
		if(sit_spawner.isSpawned()):
			var currentPose:String = sit_spawner.getScene().getState()
			var newPose:String = Util.getNextInArray(POSES, currentPose)
			sit_spawner.getScene().playStateGlobal(newPose)
	if(_id == "poseSpecific"):
		if(sit_spawner.isSpawned()):
			var _indx:int = _args[0] if _args.size() > 0 else 0
			if(_indx < 0 || _indx >= POSES.size()):
				return false
			var newPose:String = POSES[_indx]
			sit_spawner.getScene().playStateGlobal(newPose)

	if(_id == "sex"):
		var theSitterPawn := sit_spawner.getSitter("dom")
		if(!theSitterPawn):
			return false
		
		var theTargetExtra := ActionSystemTarget.new()
		theTargetExtra.node = theSitterPawn
		theTargetExtra.timerType = ActionSystemEntry.TIMER_MUST_CONSENT
		
		_action.startDelayedAction(
			"{user.You} {user.youVerb ask} to have sex with {extra0.you}!",
			_context,
			10.0,
			_context.args,
			[theTargetExtra],
		)
		
		#startSexAgainstWall(_context.pawn)
		return true

	if(_id == "forcesex"):
		var theSitterPawn := sit_spawner.getSitter("dom")
		if(!theSitterPawn):
			return false
		
		var theTargetExtra := ActionSystemTarget.new()
		theTargetExtra.node = theSitterPawn
		theTargetExtra.timerType = ActionSystemEntry.TIMER_CAN_DENY
		
		_action.startDelayedAction(
			"{user.You} {user.youVerb try|tries} to force sex with {extra0.you}!",
			_context,
			1.0,
			_context.args,
			[theTargetExtra],
		)
		return true

	return true

func doGenericDelayedAction(_id:String, _args:Array, _context:PawnActionContext, _action:PawnActionBase) -> bool:
	if(_id == "sex"):
		startSexAgainstWall(_context.pawn)
		return true
	if(_id == "forcesex"):
		startSexAgainstWall(_context.pawn)
		return true

	return true

func startSexAgainstWall(_domPawn:CharacterPawn):
	var newSex := SexStartConf.new()
	newSex.sexType = SexType.AgainstWall
	newSex.addRole("dom", _domPawn.getCharID(), SexRole.Dom)
	newSex.addRole("sub", sit_spawner.getSitter("dom").getCharID(), SexRole.Sub)
	newSex.pos = global_position
	newSex.ang = global_rotation
	sit_spawner.unsitToStandSpot("dom", stand_spot) # places the character in the right spot
	GM.sexManager.startSex(newSex)
	queue_free()

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
