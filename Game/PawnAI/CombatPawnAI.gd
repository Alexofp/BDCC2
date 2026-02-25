extends RefCounted
class_name CombatPawnAI

var pawn:CharacterPawn

#var activeEnemies:Array[CharacterPawn]
var activeEnemies:Dictionary[CharacterPawn, ActiveEnemy]

var actionQueue:Array
const ACTION_DELAY := 0 # [time]
const ACTION_DODGE := 1 # [dir:vec2(left, forward)]
const ACTION_MOVE := 2 # [dir:vec2, time]
const ACTION_BLOCK := 3 # [time]
const ACTION_ATTACK := 4
const ACTION_ATTACK_HEAVY := 5
const ACTION_WAIT_NO_MOVE := 6

var blockTime:float = 0.0
var moveDir:Vector2 = Vector2.ZERO
var moveTime:float = 0.0

var timeUntilNextMove:float = 1.0

class ActiveEnemy:
	var agroScore:float

func setPawn(_pawn:CharacterPawn):
	pawn = _pawn

func addEnemy(_pawn:CharacterPawn) -> bool:
	if(activeEnemies.has(_pawn)):
		return false
	
	var newActiveEnemy:ActiveEnemy = ActiveEnemy.new()
	newActiveEnemy.agroScore = 1.0
	
	activeEnemies[_pawn] = newActiveEnemy
	_pawn.tree_exiting.connect(removeEnemy.bind(_pawn))
	
	return true

func removeEnemy(_pawn:CharacterPawn) -> bool:
	if(!activeEnemies.has(_pawn)):
		return false
	
	_pawn.tree_exiting.disconnect(removeEnemy.bind(_pawn))
	activeEnemies.erase(_pawn)
	return true

func clearEnemies():
	if(activeEnemies.is_empty()):
		return
	for thePawn in activeEnemies.keys():
		removeEnemy(thePawn)

func hasEnemies() -> bool:
	return !activeEnemies.is_empty()

func processAI(_dt:float):
	if(!pawn):
		return
	if(pawn.isControlledByAnyPlayer()):
		return
	processTimers(_dt)
	
	var toRem:Array[CharacterPawn]
	for enemyPawn in activeEnemies:
		var theActiveEnemy:ActiveEnemy = activeEnemies[enemyPawn]
		theActiveEnemy.agroScore *= 0.9
		theActiveEnemy.agroScore += max(20.0 - pawn.global_position.distance_squared_to(enemyPawn.global_position), 0.0)
		#print(theActiveEnemy.agroScore)
		
		if(theActiveEnemy.agroScore < 0.1):
			toRem.append(enemyPawn)
	
	for thePawn in toRem:
		removeEnemy(thePawn)
	
	var theCurrentPawn := getCurrentEnemy()
	if(theCurrentPawn):
		if(moveTime <= 0.0):
			var theDist := theCurrentPawn.global_position.distance_squared_to(pawn.global_position)
			if(theDist > 1.5):
				pawn.ai.goTowards(theCurrentPawn.global_position, false)
			else:
				pawn.ai.stopWalking()
		else: # Move command
			pawn.ai.stopWalking()
			pawn.goDirLocal(moveDir, _dt, false)
		pawn.rotateTowards(theCurrentPawn.global_position)
	
	timeUntilNextMove -= _dt
	if(timeUntilNextMove <= 0.0):
		timeUntilNextMove = RNG.randfRange(2.0, 3.0)
		if(actionQueue.is_empty()):
			# Do something
			if(RNG.chance(20)):
				pushToQueue(ACTION_MOVE, [Vector2(0.0, 1.0), 0.2])
				pushDelay(0.1)
				pushToQueue(ACTION_DODGE, [Vector2(0.0, -1.0)])
				pushDelay(0.3)
				pushToQueue(RNG.pick([ACTION_ATTACK, ACTION_ATTACK_HEAVY]))
			elif(RNG.chance(50)):
				pushToQueue(ACTION_DODGE, [Vector2(1.0, 0.0)])
				pushDelay(0.8)
				pushToQueue(ACTION_DODGE, [Vector2(-1.0, 0.0)])
			else:
				pushToQueue(RNG.pick([ACTION_ATTACK, ACTION_ATTACK_HEAVY]))
				pushToQueue(ACTION_WAIT_NO_MOVE)
				pushToQueue(RNG.pick([ACTION_ATTACK, ACTION_ATTACK_HEAVY]))
				pushToQueue(ACTION_WAIT_NO_MOVE)
				pushToQueue(RNG.pick([ACTION_ATTACK, ACTION_ATTACK_HEAVY]))
				pushToQueue(ACTION_WAIT_NO_MOVE)
				pushToQueue(ACTION_BLOCK, [2.0])
	
	processQueue(_dt)
	
# Should be based on some agro score maybe
func getCurrentEnemy() -> CharacterPawn:
	if(activeEnemies.is_empty()):
		return null
	var closestEnemy:CharacterPawn = null
	var highestAgro:float = -99999.9
	for enemyPawn in activeEnemies:
		var theActiveEnemy:ActiveEnemy = activeEnemies[enemyPawn]
		if(theActiveEnemy.agroScore > highestAgro):
			closestEnemy = enemyPawn
			highestAgro = theActiveEnemy.agroScore
	
	return closestEnemy

func processQueue(_dt:float):
	while(!actionQueue.is_empty()):
		var curEntry:Array = actionQueue.front()
		var actionType:int = curEntry[0]
		var actionArgs:Array = curEntry[1]
		
		if(actionType == ACTION_DELAY):
			actionArgs[0] -= _dt
			if(actionArgs[0] > 0.0):
				break
		elif(actionType == ACTION_DODGE):
			var theDoll := pawn.getDoll()
			if(theDoll):
				if(actionArgs.size() > 0):
					theDoll.doll_controls.input_dir = actionArgs[0].normalized()
				pawn.combatMovePlayer.activateTrigger(CombatMoveBase.ACTIVATE_SHIFT)
		elif(actionType == ACTION_MOVE):
			moveDir = actionArgs[0].normalized()
			moveTime = actionArgs[1]
			var theDoll := pawn.getDoll()
			if(theDoll):
				theDoll.doll_controls.input_dir = moveDir
		elif(actionType == ACTION_BLOCK):
			blockTime = actionArgs[0]
		elif(actionType == ACTION_ATTACK):
			pawn.combatMovePlayer.activateTrigger(CombatMoveBase.ACTIVATE_ATTACK1)
		elif(actionType == ACTION_ATTACK_HEAVY):
			pawn.combatMovePlayer.activateTrigger(CombatMoveBase.ACTIVATE_SPACE)
		elif(actionType == ACTION_WAIT_NO_MOVE):
			if(pawn.combatMovePlayer.isDoingAMove()):
				break
		
		actionQueue.pop_front()

func processTimers(_dt:float):
	if(blockTime > 0.0):
		blockTime -= _dt
	if(moveTime > 0.0):
		moveTime -= _dt

func setQueue(_newQueue:Array):
	actionQueue = _newQueue

func pushToQueue(_actionID:int, _args:Array = []):
	actionQueue.append([_actionID, _args])

func pushDelay(_time:float):
	pushToQueue(ACTION_DELAY, [_time])

func clearQueue():
	actionQueue.clear()

func shouldBlock() -> bool:
	return blockTime > 0.0

func resetForPlayer():
	blockTime = 0.0
	if(!actionQueue.is_empty()):
		actionQueue.clear()
	moveTime = 0.0
