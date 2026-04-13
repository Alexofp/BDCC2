extends RefCounted
class_name SexDialogueChain

var handler:SexDialogueHandler

const ROLE_MAIN := 0
const ROLE_TARGET := 1
# extra roles here?

var id:String = ""
var roleToParticipants:Dictionary[int, SexParticipantInfo]
var participantToRole:Dictionary[SexParticipantInfo, int]

var state:String = ""
var timeOutTime:float = 0.0
var currentLines:Array[SexDialogueLine]
var wasDeleted:bool = false

var activity:SexEngineActivityBase # Optional
var supportedStates:Array[String] # if the activity is not in one of these, the chain will end

var importantChain:bool = false # if true, the sex can't end. And the AI won't do anything new

const SCORE_CONSTANT := 0
const SCORE_ANGRY := 1
const SCORE_KIND := 2

func setupChain(_handler:SexDialogueHandler, _main:SexParticipantInfo, _target:SexParticipantInfo):
	setHandler(_handler)
	involveRole(ROLE_MAIN, _main)
	involveRole(ROLE_TARGET, _target)

func involveRole(_role:int, _participant:SexParticipantInfo):
	roleToParticipants[_role] = _participant
	participantToRole[_participant] = _role

func setHandler(_dialogueHandler:SexDialogueHandler):
	handler = _dialogueHandler

func setActivity(_act:SexEngineActivityBase) -> SexDialogueChain:
	activity = _act
	return self

func setSupportedStates(_states:Array[String]):
	supportedStates = _states

func sendActivityEvent(_eventID:String, _args:Array = []):
	if(activity):
		activity.onDialogueChainEvent(self, _eventID, _args)

func start(_args:Array):
	prepareNewLines()
	checkShouldBeStopped()

func getRole(_role:int) -> SexParticipantInfo:
	if(roleToParticipants.has(_role)):
		return roleToParticipants[_role]
	return null

func getRoleByParticipant(_participant:SexParticipantInfo) -> int:
	if(participantToRole.has(_participant)):
		return participantToRole[_participant]
	return -1

var tempLines:Array[SexDialogueLine]
func getLinesFinal() -> Array[SexDialogueLine]:
	tempLines = []
	if(has_method(state+"_lines")):
		call(state+"_lines")
		return tempLines
	getLines()
	return tempLines

func getLines():
	#addLine(ROLE_MAIN, ROLE_TARGET, "SomeLine", "yep")
	pass

func prepareNewLines():
	currentLines = getLinesFinal()

func doLine(_line:SexDialogueLine):
	onLineFinal(_line)
	prepareNewLines()
	checkShouldBeStopped()

func onLineFinal(_line:SexDialogueLine) -> bool:
	if(has_method(state+"_onLine")):
		call(state+"_onLine", _line)
		return true
	return onLine(_line)

func onLine(_line:SexDialogueLine) -> bool:
	setState(_line.actionID)
	return true

func calcScoreForLine(_line:SexDialogueLine, _aiScoring:int) -> float:
	if(_aiScoring == SCORE_CONSTANT):
		return 1.0
	
	if(_aiScoring == SCORE_ANGRY):
		var theAnger := _line.main.ai.getAngerResistScore()
		return theAnger
	if(_aiScoring == SCORE_KIND):
		var theAnger := _line.main.ai.getAngerResistScore()
		return 1.0-theAnger
	
	return 1.0

func addLine(_role:int, _roleTarget:int, _line:String, _id:String, _aiScoring:int = SCORE_CONSTANT, _aiScoreMult:float = 1.0) -> SexDialogueLine:
	var theLine := SexDialogueLine.new()
	theLine.actionID = _id
	theLine.line = _line
	theLine.chain = self
	theLine.main = roleToParticipants[_role]
	theLine.target = roleToParticipants[_roleTarget]
	if(!theLine.calculateFinalLine()):
		return null
	theLine.score = calcScoreForLine(theLine, _aiScoring) * _aiScoreMult
	tempLines.append(theLine)
	return theLine

func addXLines(_amount:int, _role:int, _roleTarget:int, _line:String, _id:String, _aiScoring:int = SCORE_CONSTANT, _aiScoreMult:float = 1.0) -> SexDialogueLine:
	var theLine := SexDialogueLine.new()
	theLine.actionID = _id
	theLine.line = _line
	theLine.chain = self
	theLine.main = roleToParticipants[_role]
	theLine.target = roleToParticipants[_roleTarget]
	if(!theLine.calculateXFinalLines(_amount)):
		return null
	theLine.score = calcScoreForLine(theLine, _aiScoring) * _aiScoreMult
	tempLines.append(theLine)
	return theLine

func onIgnore():
	stopMe()

func onIgnoreAll():
	onIgnore()

func setState(_id:String):
	state = _id

func stopMe():
	handler.removeChain(self)

func shouldBeStopped() -> bool:
	if(tempLines.is_empty()):
		return true
	if(timeOutTime >= 10.0):
		return true
	if(activity && activity.wasDeleted):
		return true
	if(activity && !supportedStates.is_empty() && !(activity.getState() in supportedStates)):
		return true
	return false

func checkShouldBeStopped():
	if(shouldBeStopped()):
		stopMe()

func getState() -> String:
	return state

func addAnger(_role:int, _anger:float):
	var theInfo := getRole(_role)
	if(!theInfo):
		return
	theInfo.ai.addAnger(_anger)
