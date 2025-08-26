extends Node3D
class_name CharacterPawn

const DOLL_DESPAWN_TIME = 1.0
const DOLL_DESPAWN_DISTANCE = 30.0 * 30.0 #Squared

enum SayType {
	Speech,
	Action,
}

@export var id:String = ""
var doll:DollController
#var poseSpot:PoseSpot

@onready var doll_node: SyncNode = %DollNode
#@onready var sit_node: SyncNode = %SitNode

@onready var navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D

var ai:PawnAI
var interaction:InteractionBase

signal dollSpawned(doll)
signal dollDespawned(doll)
signal dollSwitched(newdoll, olddoll)

var gridPos:Vector2i

func _ready() -> void:
	ai = PawnAI.new()
	ai.setPawn(self)
	
	#print(sayArrayToText([
		#[SayType.Speech, "Hello."],
		#[SayType.Speech, "World."],
		#[SayType.Action, "Rubs paws"],
		#[SayType.Action, "Meows"],
		#[SayType.Speech, "Meow meow."],
		#[SayType.Speech, "Meow meow."],
	#]))
	#print(parseMeTextToArray("meows and purrs \"Hello world\" Nya"))
	#print(parseMeTextToArray("meows and purrs\naa\"Hello world\"\nNya"))
	#print(parseSayTextToArray("Hello *nuzzles you* uwu, meow meow *meows a lot*"))

func getCharacter() -> BaseCharacter:
	if(GM.characterRegistry):
		return GM.characterRegistry.getCharacter(id)
	return null

func getCharID() -> String:
	return id

func getDoll() -> DollController:
	return doll

func shouldDollBeSpawned() -> bool:
	#for playerID in Network.players:
		#var info:NetworkPlayerInfo = Network.players[playerID]
		#if(info.charID == id):
			#return true
	if(GM.pawnRegistry.shouldPawnDollBeSpawned(self)):
		return true
	return false

var despawnTimer:float = 0.0
func _process(_delta: float) -> void:
	#if(is_queued_for_deletion()): #HACK fixes a crash when hosting with NORAY, dunno
	#	return
	if(Network.isServer()):
		var shouldBeSpawned:bool = shouldDollBeSpawned()
		if(shouldBeSpawned):
			despawnTimer = 0.0
		else:
			despawnTimer += _delta
		
		if(isDollSpawned()):
			position = doll.position
			rotation = doll.model_root.rotation
			
			if(!shouldBeSpawned && despawnTimer > DOLL_DESPAWN_TIME): # || RNG.chance(1)
				despawnDoll()
		else:
			if(shouldBeSpawned): # && RNG.chance(1)
				spawnDoll()
	
	$MeshInstance3D.visible = !isDollSpawned()
	GM.pawnRegistry.checkPawnSparseGrid(self)
	

func _physics_process(_delta: float) -> void:
	#if(!isControlledByUs()):
	#	if(isDollSpawned()):
	#		getDoll().reset_input()
	ai.processAI(_delta)

func goTowardsRaw(_pos:Vector3, _delta: float, shouldRun:bool):
	if(!isDollSpawned()):
		var dirToGo:Vector3 = (_pos - global_position)
		if(dirToGo.length_squared() < 0.01):
			global_position = _pos
			return
		global_position += dirToGo.limit_length(_delta*(3.0 if !shouldRun else 5.0))
		return
	else:
		var theDoll := getDoll()
		var dirToGo:Vector3 = (_pos - global_position)
		#if(dirToGo.length_squared() < 5.0):
		#	theDoll.doll_controls.move_direction = Vector3(0.0, 0.0, 0.0)
		#	theDoll.doll_controls.move_direction_no_y = Vector3(0.0, 0.0, 0.0)
		#	return
		theDoll.doll_controls.move_direction = dirToGo.normalized()
		theDoll.doll_controls.move_direction_no_y = theDoll.doll_controls.move_direction
		theDoll.doll_controls.move_direction_no_y.y = 0.0
		theDoll.doll_controls.move_direction_no_y = theDoll.doll_controls.move_direction_no_y.normalized()
		theDoll.doll_controls.sprint_isdown = shouldRun

func isDollSpawned() -> bool:
	return !!doll

func spawnDoll():
	if(!Network.isServer()):
		return
	if(doll):
		assert(false, "Doll already spawned")
		return
	var newDoll: = GM.dollHolder.createDollControllerForPawn(self)
	newDoll.tree_exiting.connect(dollOnDelete)
	doll_node.setNode(newDoll)

func despawnDoll():
	if(!doll):
		assert(false, "Doll doesn't exist")
		return
	GM.dollHolder.deleteDoll(doll)
	doll_node.setNode(null)

func dollOnDelete():
	doll_node.setNode(null)

func isControlledByUs() -> bool:
	var myInfo:NetworkPlayerInfo = Network.getMyPlayerInfo()
	if(!myInfo):
		return false
	return myInfo.charID == id

func saveNetworkData() -> Dictionary:
	return {
		pos = position,
	}

func loadNetworkData(_data:Dictionary):
	position = SAVE.loadVar(_data, "pos", position)

func _on_doll_node_on_node_changed(newNode: Variant) -> void:
	var tempDoll = doll
	doll = newNode
	
	if(doll):
		Log.Print("Doll spawned for "+getCharID())
		doll.updatePoseSpot()
		dollSpawned.emit(doll)
	elif(tempDoll && !doll):
		Log.Print("Doll despawned for "+getCharID())
		dollDespawned.emit(tempDoll)
	if(doll != tempDoll):
		dollSwitched.emit(doll, tempDoll)

#func _on_sit_node_on_node_changed(newNode: Variant) -> void:
	#poseSpot = newNode
	# # Notify doll
	#var theDoll:=getDoll()
	#if(theDoll):
		#theDoll.updatePoseSpot()
#
#func setPoseSpot(newPoseSpot:PoseSpot):
	#if(Network.isClient()):
		#assert(false, "Client trying to set pose spot. Only server should do it")
		#return
	#sit_node.setNode(newPoseSpot)

func getPoseSpot() -> PoseSpot:
	return GM.sitManager.getSeatOfPawn(self)

func _exit_tree() -> void:
	GM.sitManager.handleDeletionOfPawn(self)
	if(Network.isServer()):
		if(doll):
			despawnDoll()

func canSit() -> bool:
	return !GM.sitManager.isSitting(self)

## Called by sit manager
func onSeatChange(_newSpot:PoseSpot):
	var theDoll := getDoll()
	if(theDoll):
		theDoll.onSeatChange(_newSpot)

func getNavAgent() -> NavigationAgent3D:
	return navigation_agent_3d

func getAI() -> PawnAI:
	return ai

func hasInteraction() -> bool:
	return interaction != null

func getInteraction() -> InteractionBase:
	return interaction

func setInteraction(_int:InteractionBase):
	interaction = _int

static func sayArrayToText(theStuff:Array) -> String:
	var result:String = ""
	for stuffEntry in theStuff:
		var entryType:int = stuffEntry[0]
		
		if(!result.is_empty()):
			result += " "
		
		if(entryType == SayType.Speech):
			result += stuffEntry[1]
		if(entryType == SayType.Action):
			result += "*"+stuffEntry[1]+"*"
			
	return result

static func sayArrayToMeText(theStuff:Array) -> String:
	var result:String = ""
	for stuffEntry in theStuff:
		var entryType:int = stuffEntry[0]
		
		if(!result.is_empty()):
			result += " "
		
		if(entryType == SayType.Speech):
			result += "\""+stuffEntry[1]+"\""
		if(entryType == SayType.Action):
			result += stuffEntry[1]
			
	return result

static func sayArrayToChatTextSmart(charName:String, theStuff:Array) -> String:
	if(theStuff.is_empty()):
		return ""
	var firstType:Array = theStuff.front()
	if(firstType[0] == SayType.Speech):
		return charName+": "+sayArrayToText(theStuff)
	elif(firstType[0] == SayType.Action):
		return charName+" "+sayArrayToMeText(theStuff)
	else:
		return "error?"

static func parseMeTextToArray(_theText:String) -> Array:
	var result:Array = []
	
	var curText:String = ""
	var curToken:int = SayType.Action
	
	for theLetter in _theText:
		if(theLetter == "\""):
			if(curText != ""):
				result.append([curToken, curText.strip_edges()])
				curText = ""
			if(curToken == SayType.Action):
				curToken = SayType.Speech
			else:
				curToken = SayType.Action
		else:
			curText += theLetter
	
	if(curText != ""):
		result.append([curToken, curText.strip_edges()])
		curText = ""
	
	return result

static func parseSayTextToArray(_theText:String) -> Array:
	var result:Array = []
	
	var curText:String = ""
	var curToken:int = SayType.Speech
	
	for theLetter in _theText:
		if(theLetter == "*"):
			if(curText != ""):
				result.append([curToken, curText.strip_edges()])
				curText = ""
			if(curToken == SayType.Action):
				curToken = SayType.Speech
			else:
				curToken = SayType.Action
		else:
			curText += theLetter
	
	if(curText != ""):
		result.append([curToken, curText.strip_edges()])
		curText = ""
	
	return result

static func getStuffTalkLen(stuff:Array) -> float:
	var result:float = 0.0
	for stuffEntry in stuff:
		#TODO: Make this depend on amount of speech
		if(stuffEntry[0] == SayType.Speech):
			result = 3.0
	return result

func sayAdvanced(stuff:Array):
	GM.pawnRegistry.sayAdvanced(self, stuff)

func sayAdvancedLocal(stuff:Array):
	# Spread this to nearby dolls to hear?
	#var theText:String = sayArrayToText(stuff)
	
	#if(isDollSpawned()):
		#var theDoll := getDoll()
		
		# Hover text maybe should happen in hear
		# But if the pc isn't controlling a doll, we do it here
		#theDoll.addHoverText(theText)
	
	if(isDollSpawned()):
		var theSpeechTime:float = getStuffTalkLen(stuff)
		if(theSpeechTime > 0.0):
			getDoll().getDoll().doFaceTalkAnim(theSpeechTime)
	
	var nearbyPawns := GM.pawnRegistry.getPawnsNear(global_position, 20.0)
	for theOtherPawn in nearbyPawns:
		#if(theOtherPawn == self):
		#	continue
		theOtherPawn.hearAdvanced(self, stuff)
		#theOtherPawn.addHoverText("I HEAR!")

func hearAdvanced(otherPawn:CharacterPawn, stuff:Array):
	if(isControlledByUs()):
		sendToChatLocal(sayArrayToChatTextSmart(otherPawn.getCharacter().getName(), stuff))
		var theText:String = sayArrayToText(stuff)
		otherPawn.addHoverText(theText)
		
func sendToChatLocal(rawText:String):
	if(isControlledByUs()):
		GameChat.addChat(rawText)

func addHoverText(_text:String):
	if(isDollSpawned()):
		var theDoll := getDoll()
		theDoll.addHoverText(_text)

func playGesture(_gestureID:String):
	if(isDollSpawned()):
		var theDoll := getDoll()
		GM.dollHolder.playGesture(theDoll, _gestureID)

func isFullbodyGesturesBlocked() -> bool:
	var theChar := getCharacter()
	if(!theChar):
		return false
	return theChar.isFullbodyGesturesBlocked()

func isPartialGesturesBlocked() -> bool:
	var theChar := getCharacter()
	if(!theChar):
		return false
	return theChar.isPartialGesturesBlocked()
