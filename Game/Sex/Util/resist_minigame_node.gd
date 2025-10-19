extends Node
class_name ResistMinigameNode

const RESIST_START = 0
const RESIST_UPDATE = 1
const RESIST_END = 2

const STATE_DISABLED = 0
const STATE_INTRO = 1
const STATE_MAIN = 2
const STATE_END = 3

var state:int = STATE_DISABLED

var introTime:float = 0.0
var time:float = 0.0
var timeFull:float = 0.0

var endTime:float = 2.0

var resultMarks:Dictionary[String, float] = {}
var resultText:String = ""

var target:float = 0.5
var yellowZone:float = 0.1

var team1name:String = "Team 1"
var team1:Array[String] = []
var team2name:String = "Team 2"
var team2:Array[String] = []

var speeds:Dictionary[String, float] = {}
var times:Dictionary[String, float] = {}

var shouldShowIntro:bool = true

signal onUpdate(updateType:int)
signal onResult(_result:ResistMinigameResult)

# runs on server
func updateMinigame(_dt:float):
	if(state == STATE_INTRO):
		introTime -= _dt
		if(introTime <= 0.0):
			state = STATE_MAIN
			syncMinigame()
		return
	
	elif(state == STATE_MAIN):
		time -= _dt
		
		#for charID in times:
		#	if(resultMarks.has(charID)):
		#		continue
		#	times[charID] += _dt * (speeds[charID] if speeds.has(charID) else 1.0)
		
		if(time < 0.0 || resultMarks.size() >= (team1.size() + team2.size())):
			time = 0.0
			state = STATE_END
			
			#var winnerID:String = getWinnerCharID()
			var team1win:bool = didTeam1Win()
			#if(team2.has(winnerID)):
			#	didTeam1Win = false
			
			if(team1win):
				resultText = team1name + " won!"
			else:
				resultText = team2name + " won!"
			syncMinigame()
		return
	
	elif(state == STATE_END):
		endTime -= _dt
		if(endTime <= 0.0):
			state = STATE_DISABLED
			
			var resistResult:ResistMinigameResult = ResistMinigameResult.new()
			resistResult.team1win = didTeam1Win()
			
			onResult.emit(resistResult)

func isDisabled() -> bool:
	return state == STATE_DISABLED

func getWinnerCharID() -> String:
	if(resultMarks.is_empty()):
		return ""
	var closestCharID:String = ""
	var closestScore:float = -999.9
	
	for charID in resultMarks:
		var theResPos:float = resultMarks[charID]
		var theRes:float = 1.0 - abs(target - theResPos)
		if(theRes > closestScore):
			closestScore = theRes
			closestCharID = charID
	return closestCharID

func didTeam1Win() -> bool:
	var theWinner := getWinnerCharID()
	if(theWinner.is_empty()):
		return true
	return !team2.has(theWinner)

func setTeams(_team1name:String, _team1:Array[String], _team2name:String, _team2:Array[String]):
	team1 = _team1
	team1name = _team1name
	team2 = _team2
	team2name = _team2name

func saveData() -> Dictionary:
	return {
		introTime = introTime,
		time = time,
		timeFull = timeFull,
		state = state,
		resultText = resultText,
		target = target,
		yellowZone = yellowZone,
		team1 = team1,
		team1name = team1name,
		team2 = team2,
		team2name = team2name,
		resultMarks = resultMarks,
	}

func loadData(_data:Dictionary):
	introTime = SAVE.loadVar(_data, "introTime", 0.0)
	time = SAVE.loadVar(_data, "time", 0.0)
	timeFull = SAVE.loadVar(_data, "timeFull", 0.0)
	state = SAVE.loadVar(_data, "state", STATE_INTRO)
	resultText = SAVE.loadVar(_data, "resultText", "")
	target = SAVE.loadVar(_data, "target", 0.0)
	yellowZone = SAVE.loadVar(_data, "yellowZone", 0.1)
	team1 = SAVE.loadVar(_data, "team1", [])
	team1name = SAVE.loadVar(_data, "team1name", "")
	team2 = SAVE.loadVar(_data, "team2", [])
	team2name = SAVE.loadVar(_data, "team2name", "")
	resultMarks = SAVE.loadVar(_data, "resultMarks", {})

func syncMinigame():
	onUpdate.emit(RESIST_UPDATE)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(syncMinigame_RPC.bind(saveData()))

@rpc("authority", "call_remote", "reliable")
func syncMinigame_RPC(_data:Dictionary):
	loadData(_data)
	onUpdate.emit(RESIST_UPDATE)

func getCurTime(_charID:String) -> float:
	if(times.has(_charID)):
		return times[_charID]
	return 0.0

func getCurSpeed(_charID:String) -> float:
	if(speeds.has(_charID)):
		return speeds[_charID]
	return 1.0

func startMinigame(_speedDom:float, _speedSub:float):
	var newTarget:float = RNG.randfRange(0.0, 1.0)
	var newYellowZone:float = 0.1
	
	var theIntroTime:float = 2.0 if shouldShowIntro else 0.5
	shouldShowIntro = false
	
	for charID in team1:
		speeds[charID] = RNG.randfRange(0.8, 1.2) * _speedDom
		times[charID] = RNG.randfRange(0.0, 20.0)
	
	for charID in team2:
		speeds[charID] = RNG.randfRange(0.8, 1.2) * _speedSub
		times[charID] = RNG.randfRange(0.0, 20.0)
	
	startMinigame_RPC(theIntroTime, newTarget, newYellowZone, times, speeds)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(startMinigame_RPC.bind(theIntroTime, newTarget, newYellowZone, times, speeds))

@rpc("authority", "call_remote", "reliable")
func startMinigame_RPC(theIntroTime:float, theTarget:float, theYellowZone:float, theTimes:Dictionary[String, float], theSpeeds:Dictionary[String, float]):
	state = STATE_INTRO
	introTime = theIntroTime
	timeFull = 10.0
	time = timeFull
	resultMarks = {}
	target = theTarget
	yellowZone = theYellowZone
	endTime = 2.0
	resultText = ""
	times = theTimes
	speeds = theSpeeds
	
	onUpdate.emit(RESIST_START)

func stopResistMinigame():
	stopResistMinigame_RPC()
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(stopResistMinigame_RPC)

@rpc("authority", "call_remote", "reliable")
func stopResistMinigame_RPC():
	state = STATE_DISABLED
	onUpdate.emit(RESIST_END)

func pushResult(_charID:String, _result:float):
	if(Network.isClient()):
		pushResult_SERVERRPC.rpc_id(1, _charID, _result)
	else:
		pushResult_SERVERRPC(_charID, _result)

@rpc("any_peer", "call_remote", "reliable")
func pushResult_SERVERRPC(_charID:String, _result:float):
	if(!team1.has(_charID) && !team2.has(_charID)):
		return
	if(resultMarks.has(_charID)): # Prevents re-submitting the result
		return
	resultMarks[_charID] = _result
	syncMinigame()
