extends RefCounted
class_name PawnPoseHandler

var pawn:CharacterPawn

const POSE_IDLE := 0
const POSE_ARMS := 1

# Synced with CharacterPawn's SyncRare node
var idle:String = ""
var idlePose:DollPoseBase
var arms:String = ""
var armsPose:DollPoseBase

# Cached values for the doll, updated once every frame
var idleEntry:DollAnimEntry
var walkEntry:DollAnimEntry
var runEntry:DollAnimEntry

#var idleAnim:String = "IdleUnisex"
#var walkAnim:String = "WalkUnisex"
#var walkSpeed:float = 1.0
#var runAnim:String = "Run"
#var runSpeed:float = DollController.RUN_MULT_DEFAULT
var runAllowed:bool = true
var jumpHeight:float = 1.0
var gestureFullbodyBlocked:bool = false
var gesturePartialBlocked:bool = false
var hasLeashesInRightHand:bool = false
# runAnim/runSpeed?

func _init() -> void:
	idleEntry = DollAnimEntry.create("IdleUnisex")
	walkEntry = DollAnimEntry.create("WalkUnisex")
	runEntry = DollAnimEntry.create("Run")

func tickAI(_dt:float):
	if(pawn.submission.isObeying()):
		return
	idle = ""
	arms = ""

func getOr(_anim:String, _alt:String) -> String:
	if(_anim.is_empty()):
		return _alt
	return _anim

func process(_dt:float):
	if(!pawn):
		return
	var theCharacter:BaseCharacter = pawn.getCharacter()
	if(!theCharacter):
		return
	var theBoundFlags := theCharacter.buffsHolder.boundFlags
	
	var theIdlePose := getIdle()
	var theArmsPose := getArms()
	var areLegsHobbled := theCharacter.inventory.shouldHobbleLegs()
	
	var idleAnim:String = theCharacter.idleAnim
	var walkAnim:String = theCharacter.walkAnim
	var runAnim:String = "Run"
	runAllowed = true
	jumpHeight = 1.0
	
	if(areLegsHobbled):
		walkAnim = "WalkHobbled"
		runAnim = "WalkHobbledFast"
		#walkSpeed = 0.5
		runAllowed = true
		jumpHeight = 0.5
	
	if(theIdlePose):
		idleAnim = getOr(theIdlePose.getAnimName(theBoundFlags), idleAnim)
		walkAnim = getOr(theIdlePose.getWalkAnimName(theBoundFlags), walkAnim)
		runAnim = getOr(theIdlePose.getRunAnimName(theBoundFlags), runAnim)
		runAllowed = !theIdlePose.preventsSprint()
		#jumpHeight = 1.0
	
	idleEntry.setID(idleAnim)
	walkEntry.setID(walkAnim)
	runEntry.setID(runAnim)
	
	gestureFullbodyBlocked = false
	gesturePartialBlocked = false
	if((theIdlePose && theIdlePose.doesPreventFullbodyGestures()) || (theArmsPose && theArmsPose.doesPreventFullbodyGestures())):
		gestureFullbodyBlocked = true
	if((theIdlePose && theIdlePose.doesPreventPartialGestures()) || (theArmsPose && theArmsPose.doesPreventPartialGestures())):
		gesturePartialBlocked = true

func processRare(_dt:float):
	hasLeashesInRightHand = GM.main.leash_system.hasAnyLeashesInRightHand(pawn) && !gestureFullbodyBlocked && !gesturePartialBlocked
	if(pawn.pawnState != CharacterPawn.STATE_NORMAL):
		hasLeashesInRightHand = false
	
func setPawn(_p:CharacterPawn):
	pawn = _p

func getIdle() -> DollPoseBase:
	if(idle.is_empty()):
		return null
	if(!idlePose || idlePose.id != idle):
		idlePose = GlobalRegistry.getDollPose(idle)
	return idlePose

func getArms() -> DollPoseBase:
	if(arms.is_empty()):
		return null
	if(!armsPose || armsPose.id != arms):
		armsPose = GlobalRegistry.getDollPose(arms)
	return armsPose

func setIdle(_id:String):
	idle = _id

func setArms(_id:String):
	arms = _id

func setPoseOf(_type:int, _value:String):
	if(_type == POSE_IDLE):
		setIdle(_value)
	elif(_type == POSE_ARMS):
		setArms(_value)

func getPoseOf(_type:int) -> String:
	if(_type == POSE_IDLE):
		return idle
	elif(_type == POSE_ARMS):
		return arms
	return ""

func saveData() -> Dictionary:
	return {
		idle = idle,
		arms = arms,
	}

func loadData(_data:Dictionary):
	idle = SAVE.loadVar(_data, "idle", "")
	arms = SAVE.loadVar(_data, "arms", "")

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.StrShort, idle,
		Bins.StrShort, arms,
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	idle = _data.readStrShort()
	arms = _data.readStrShort()
	_data.endLoad()
