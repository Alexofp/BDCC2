extends RefCounted
class_name CombatMoveBase

var id:String = "ERROR"

var priority:int = 0 # Higher -> The move will be checked first
var conditions:Array[Array] = [
	#[COND_TAG, "ap1"], # Required tag 'ap1' to be active
]
const COND_TAG = 0
const COND_NO_TAG = 1

var initialEffects:Array = [
	#[EFFECT_DELAY, 0.5],
	#[EFFECT_EVENT, "test"],
	#[EFFECT_TAG, "ap1", 0.5], # ap1 = after punch 1
]
const EFFECT_EVENT = 0
const EFFECT_HIT = 1
const EFFECT_DELAY = 2
const EFFECT_TAG = 3
const EFFECT_MOVE = 4

var activateType:int = ACTIVATE_NOTHING
const ACTIVATE_NOTHING = 0
const ACTIVATE_ATTACK1 = 1 # Normal attacks
const ACTIVATE_SHIFT = 2 # Dodging usually
const ACTIVATE_SPACE = 3 # Heavy attacks like kicking


var animation:String = ""
var moveLen:float = 1.0
var noMoveLen:float = 1.0
var canCancelExistingMove:bool = false

const TAG_DODGING = "dd"
const TAG_AFTER_DODGE = "ad"

func canUse(_player:CombatMovePlayer) -> bool:
	return true

# Runs only on server
func onEvent(_player:CombatMovePlayer, _eventID:String, _args:Array):
	Log.Print("COMBAT MOVE EVENT! move="+id+" EVENT ID="+_eventID)
	pass

func onStrike(_player:CombatMovePlayer, _attackInfo:AttackInfo):
	_player.doStrike(_attackInfo)

func startMove(_player:CombatMovePlayer):
	consumeConditionTags(_player)
	pushToEffectsQueue(_player, initialEffects.duplicate(true))
	_player.pawn.doCombatAnim(animation)

func pushToEffectsQueue(_player:CombatMovePlayer, _ar:Array):
	_player.pushToEffectsQueue(_ar)

func canUseMoveFinal(_player:CombatMovePlayer) -> bool:
	if(!canCancelExistingMove && _player.isDoingAMove()):
		return false
	
	for condEntry in conditions:
		var entryType:int = condEntry[0]
		
		if(entryType == COND_TAG):
			if(!_player.hasTag(condEntry[1])):
				return false
		elif(entryType == COND_NO_TAG):
			if(_player.hasTag(condEntry[1])):
				return false
	
	return canUse(_player)

func consumeConditionTags(_player:CombatMovePlayer):
	for condEntry in conditions:
		var entryType:int = condEntry[0]
		
		if(entryType == COND_TAG):
			_player.eraseTag(condEntry[1])
