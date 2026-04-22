extends RefCounted
class_name CombatPawnAI

var pawn:CharacterPawn

#var activeEnemies:Array[CharacterPawn]
var activeEnemies:Dictionary[CharacterPawn, ActiveEnemy]
var recentlyDefeatedEnemies:Dictionary[CharacterPawn, RecentlyDefeatedEnemy]

var actionQueue:Array
const ACTION_DELAY := 0 # [time]
const ACTION_DODGE := 1 # [dir:vec2(left, forward)]
const ACTION_MOVE := 2 # [dir:vec2, time]
const ACTION_BLOCK := 3 # [time]
const ACTION_ATTACK := 4
const ACTION_ATTACK_HEAVY := 5
const ACTION_WAIT_NO_MOVE := 6
const ACTION_ATTACK_PICK := 7

var blockTime:float = 0.0
var moveDir:Vector2 = Vector2.ZERO
var moveTime:float = 0.0

var timeUntilNextMove:float = 1.0
var blockChainTimer:float = 0.0 # if above > 0.0, the AI will block/dodge every move
var gotHitDanger:float = 0.0

var runsToApproach:bool = false

var comboContext:AIComboContext = AIComboContext.new()

class RecentlyDefeatedEnemy:
	var timer:float

class ActiveEnemy:
	var agroScore:float

func setPawn(_pawn:CharacterPawn):
	pawn = _pawn
	comboContext.pawn = _pawn

func addRecentlyDefeatedEnemy(_pawn:CharacterPawn) -> bool:
	if(!_pawn || recentlyDefeatedEnemies.has(_pawn)):
		return false
	var newRecentlyDefeatedEnemy:RecentlyDefeatedEnemy = RecentlyDefeatedEnemy.new()
	newRecentlyDefeatedEnemy.timer = 5.0
	recentlyDefeatedEnemies[_pawn] = newRecentlyDefeatedEnemy
	_pawn.tree_exiting.connect(removeRecentlyDefeatedEnemy.bind(_pawn))
	Log.Print("ADDED RECENTLY DEFEATED ENEMY: "+str(_pawn))
	return true

func removeRecentlyDefeatedEnemy(_pawn:CharacterPawn) -> bool:
	if(!recentlyDefeatedEnemies.has(_pawn)):
		return false
	_pawn.tree_exiting.disconnect(removeRecentlyDefeatedEnemy.bind(_pawn))
	recentlyDefeatedEnemies.erase(_pawn)
	Log.Print("REMOVED DEFEATED ENEMY: "+str(_pawn))
	return true

func clearRecentlyDefeatedEnemies():
	if(recentlyDefeatedEnemies.is_empty()):
		return
	for thePawn in recentlyDefeatedEnemies.keys():
		removeRecentlyDefeatedEnemy(thePawn)

func addEnemy(_pawn:CharacterPawn) -> bool:
	if(!_pawn || activeEnemies.has(_pawn)):
		return false
	if(_pawn == pawn):
		return false
	if(pawn.shouldIgnoreAttackTowards(_pawn)):
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

func hasEnemy(_pawn:CharacterPawn) -> bool:
	return activeEnemies.has(_pawn)

func clearEnemies():
	if(activeEnemies.is_empty()):
		return
	for thePawn in activeEnemies.keys():
		removeEnemy(thePawn)

func hasEnemies() -> bool:
	return !activeEnemies.is_empty()

func addEnemyDanger(_pawn:CharacterPawn, _d:float):
	if(!hasEnemy(_pawn)):
		return
	activeEnemies[_pawn].agroScore += _d

var toRem:Array[CharacterPawn]
func processRare(_dt:float):
	if(pawn.isControlledByAnyPlayer()):
		return
	toRem.clear()
	for enemyPawn in recentlyDefeatedEnemies:
		var theRecentlyDefeatedEnemy:RecentlyDefeatedEnemy = recentlyDefeatedEnemies[enemyPawn]
		theRecentlyDefeatedEnemy.timer -= _dt
		if(!enemyPawn.isDefeated() || theRecentlyDefeatedEnemy.timer <= 0.0 || enemyPawn.global_position.distance_squared_to(pawn.global_position) > 400.0):
			toRem.append(enemyPawn)
	for thePawn in toRem:
		removeRecentlyDefeatedEnemy(thePawn)
	
	toRem.clear()
	for enemyPawn in activeEnemies:
		var theActiveEnemy:ActiveEnemy = activeEnemies[enemyPawn]
		theActiveEnemy.agroScore *= 0.9
		theActiveEnemy.agroScore += maxf(30.0 - pawn.global_position.distance_squared_to(enemyPawn.global_position), 0.0)
		#print(theActiveEnemy.agroScore)
		
		if(theActiveEnemy.agroScore < 0.1):
			toRem.append(enemyPawn)
		elif(enemyPawn.isDefeated()):
			toRem.append(enemyPawn)
			addRecentlyDefeatedEnemy(enemyPawn)
		elif(pawn.shouldIgnoreAttackTowards(enemyPawn)):
			toRem.append(enemyPawn)
	for thePawn in toRem:
		removeEnemy(thePawn)

func shouldDoFakeCombatWith(_otherPawn:CharacterPawn) -> bool:
	if(!pawn.isDollSpawned()):
		return true
	if(!_otherPawn.isDollSpawned()):
		return true
	return false

func doFakeCombat(_otherPawn:CharacterPawn):
	timeUntilNextMove = RNG.randfRange(0.7, 3.0)
	if(!_otherPawn):
		return
	if(!pawn.canDoFakeCombat()):
		return
	pawn.combatMovePlayer.doFakeStrike(_otherPawn, RNG.randfRange(0.3, 0.5))

func processAI(_dt:float):
	if(!pawn):
		return
	if(pawn.isControlledByAnyPlayer()):
		return
	processTimers(_dt)
	
	var theCurrentPawn := getCurrentEnemy()
	if(theCurrentPawn):
		if(isSitting()):
			getUpIfSitting()
			return
		
		if(moveTime <= 0.0):
			var theDist := theCurrentPawn.global_position.distance_squared_to(pawn.global_position)
			if(runsToApproach):
				if(theDist < 10.0):
					runsToApproach = false
			else:
				if(theDist > 15.0 && RNG.chance(10.0)):
					runsToApproach = true
			
			if(theDist > 1.5):
				if(pawn.combatMovePlayer.hasTag(CombatMoveBase.TAG_ROLLING)):
					pawn.ai.stopWalking()
				else:
					pawn.ai.goTowards(theCurrentPawn.global_position, runsToApproach)
			else:
				pawn.ai.stopWalking()
		else: # Move command
			pawn.ai.stopWalking()
			pawn.goDirLocal(moveDir, _dt, false)
		pawn.rotateTowards(theCurrentPawn.global_position)
	
	if(blockChainTimer > 0.0):
		blockChainTimer -= _dt
	if(gotHitDanger > 0.0):
		gotHitDanger *= 0.97
		if(gotHitDanger < 0.2):
			gotHitDanger = 0.0
	#print(gotHitDanger)
	
	timeUntilNextMove -= _dt
	if(theCurrentPawn && theCurrentPawn.isCollapsed()):
		timeUntilNextMove = min(timeUntilNextMove, 0.1)
	if(theCurrentPawn && timeUntilNextMove <= 0.0):
		if(shouldDoFakeCombatWith(theCurrentPawn)):
			doFakeCombat(theCurrentPawn)
		else:
			tryToStartCombo(theCurrentPawn)
	
	processQueue(_dt)

func tryToStartCombo(_target:CharacterPawn):
	if(!actionQueue.is_empty()):
		timeUntilNextMove = RNG.randfRange(0.5, 1.0)
		return
	
	var possible:Array[AIComboBase]
	var possibleWeight:Array[float]
	
	comboContext.target = _target
	comboContext.distance = pawn.getGlobalPos().distance_to(_target.getGlobalPos())
	#print(comboContext.distance)
	
	for theCombo in GlobalRegistry.getAICombos():
		if(!theCombo.canDoCombo(comboContext)):
			continue
		var theScore := theCombo.getComboScore(comboContext)
		if(theScore <= 0.0):
			continue
		possible.append(theCombo)
		possibleWeight.append(theScore)
	
	if(possible.is_empty()):
		timeUntilNextMove = RNG.randfRange(0.5, 1.0)
		clearComboContext()
		return
	
	var randomCombo:AIComboBase = RNG.pickWeighted(possible, possibleWeight)
	if(!randomCombo):
		timeUntilNextMove = RNG.randfRange(0.5, 1.0)
		clearComboContext()
		return
	
	randomCombo.doCombo(comboContext)
	randomCombo.doComboEffects(comboContext)
	clearComboContext()
	#if(actionQueue.is_empty() && pawn.combatMovePlayer.getExhaustionLevel() <= 0.4):

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
					theDoll.doll_controls.input_dir = actionArgs[0].normalized() * Vector2(1.0, -1.0)
				pawn.combatMovePlayer.activateTrigger(CombatMoveBase.ACTIVATE_SHIFT)
		elif(actionType == ACTION_MOVE):
			moveDir = actionArgs[0].normalized()
			moveTime = actionArgs[1]
			var theDoll := pawn.getDoll()
			if(theDoll):
				theDoll.doll_controls.input_dir = moveDir*Vector2(1.0, -1.0)
		elif(actionType == ACTION_BLOCK):
			blockTime = actionArgs[0]
		elif(actionType == ACTION_ATTACK):
			pawn.combatMovePlayer.activateTrigger(CombatMoveBase.ACTIVATE_ATTACK1)
		elif(actionType == ACTION_ATTACK_HEAVY):
			pawn.combatMovePlayer.activateTrigger(CombatMoveBase.ACTIVATE_SPACE)
		elif(actionType == ACTION_ATTACK_PICK):
			pawn.combatMovePlayer.activateTrigger(RNG.pick([CombatMoveBase.ACTIVATE_SPACE, CombatMoveBase.ACTIVATE_ATTACK1]))
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

func isSitting() -> bool:
	return pawn.isSittingSomewhere()

func getUpIfSitting():
	var curPoseSpot := GM.sitManager.getSeatOfPawn(pawn)
	if(!curPoseSpot):
		return
		
	var theHandler := curPoseSpot.getHandler()
	if(theHandler is PropHandlerBase):
		var ourSlot:String = theHandler.getSlotOfPawn(pawn)
		if(ourSlot.is_empty()):
			return
		
		if(!theHandler.canGetUpFromSlot(ourSlot)):
			#impossibleAction()
			return
		
		var _doAct := pawn.doInteractEntryDo(InteractEntryDo.create(
			"SitProp", [ourSlot],
		), theHandler)
	return

func recoverIfDefeated():
	if(!pawn.isDefeated()):
		return
	if(!pawn.canRecoverFromDefeat()):
		return
	if(pawn.isDoingSomething()):
		return
	
	var _doAct := pawn.doInteractEntryDo(InteractEntryDo.create("DefeatedGetUp"), pawn)
	
func onNearbyPawnStartMove(_otherPawn:CharacterPawn, _someMove:CombatMoveBase):
	if(!hasEnemy(_otherPawn)):
		return
	addEnemyDanger(_otherPawn, 3.0)
	
	var theClosestAttackEntry := _otherPawn.combatMovePlayer.getClosestHitEntry()
	if(theClosestAttackEntry.is_empty()):
		return
	
	var timeBeforeHit:float = theClosestAttackEntry[0]
	var _theAttack:AttackInfo = theClosestAttackEntry[1]
	# Check if the attack would hit us (with some extra padding to account for movement)
	if(!_otherPawn.combatMovePlayer.willAttackHitTarget(pawn, _theAttack)):
		return
	var _canBlock:bool = pawn.combatMovePlayer.canBlock()
	var _canDodge:bool = pawn.combatMovePlayer.canDodge()
	
	if(!_canBlock && !_canDodge):
		return
	
	if(blockChainTimer <= 0.0):
		#var theStartBlockingChance := 20.0
		var theStartBlockingChance := pawn.getCharacter().combatAI.defenseReaction*100.0
		
		if(RNG.chance(theStartBlockingChance * maxf(gotHitDanger, 1.0))):
			blockChainTimer = 1.0
		else:
			return
	
	blockChainTimer = maxf(1.0, blockChainTimer)
	
	clearQueue()
	
	var blockScore:float = (1.05 - pawn.combatMovePlayer.getStrain()) if _canBlock else 0.0
	var dodgeScore:float = 0.1 if _canDodge else 0.0
	var rollScore:float = 0.02 if _canDodge else 0.0
	
	var theAction = RNG.pickWeighted([0, 1, 2], [blockScore, dodgeScore, rollScore])
	
	if(theAction == null):
		return
	elif(theAction == 0): # Block
		pushDelay(timeBeforeHit*RNG.randfRange(0.2, 0.6))
		pushToQueue(ACTION_BLOCK, [maxf(timeBeforeHit*0.5, 0.5)])
	elif(theAction == 1): # Dodge
		pushDelay(timeBeforeHit*RNG.randfRange(0.2, 0.6))
		pushToQueue(ACTION_DODGE, [RNG.pick([
			Vector2(0.0, -1.0),
			Vector2(1.0, 0.0),
			Vector2(-1.0, 0.0),
		])])
	elif(theAction == 2): # Roll
		pushDelay(timeBeforeHit*RNG.randfRange(0.2, 0.6))
		var theDir:Vector2 = RNG.pick([
			#Vector2(0.0, -1.0),
			Vector2(1.0, 0.0),
			Vector2(-1.0, 0.0),
		])
		pushToQueue(ACTION_DODGE, [theDir])
		pushDelay(0.1)
		pushToQueue(ACTION_MOVE, [theDir, 0.1])
		pushToQueue(ACTION_DODGE, [theDir])

func onHit(_attackContext:AttackContext):
	if(pawn.isControlledByAnyPlayer()):
		return
	#var theAttack := _attackContext.attack
	
	if(!_attackContext.blocked):
		gotHitDanger += 1.0
	addEnemyDanger(_attackContext.attacker, 5.0)
		
func clearComboContext():
	comboContext.target = null
	comboContext.distance = 0.0
