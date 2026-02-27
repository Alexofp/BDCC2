extends RefCounted
class_name CombatMoveBase

var id:String = "ERROR"

var priority:int = 0 # Higher -> The move will be checked first
var conditions:Array[Array] = [
	#[COND_TAG, "ap1"], # Required tag 'ap1' to be active
]
const COND_TAG = 0
const COND_NO_TAG = 1
const COND_TAG_ANY = 2
const COND_JUST_CONSUME = 3

var initialEffects:Array = [
	#[EFFECT_DELAY, 0.5],
	#[EFFECT_EVENT, "test"],
	#[EFFECT_TAG, "ap1", 0.5], # ap1 = after punch 1
]
var cancelEffects:Array = []
const EFFECT_EVENT = 0
const EFFECT_HIT = 1
const EFFECT_DELAY = 2
const EFFECT_TAG = 3
const EFFECT_MOVE = 4
const EFFECT_SOUND = 5
const EFFECT_EXHAUSTION = 6

var activateType:int = ACTIVATE_NOTHING
const ACTIVATE_NOTHING = 0
const ACTIVATE_ATTACK1 = 1 # Normal attacks
const ACTIVATE_SHIFT = 2 # Dodging usually
const ACTIVATE_SPACE = 3 # Heavy attacks like kicking


var animation:String = ""
var moveLen:float = 1.0
var noMoveLen:float = 1.0
var canCancelExistingMove:bool = false
var followVelocityDir:bool = false
var requiresStamina:bool = true
var exhaustionOnStart:float = 0.0

const TAG_DODGING = "dd"
const TAG_DODGING_FORWARD = "ddf"
const TAG_AFTER_DODGE = "ad"
const TAG_CAN_ROLL = "cr"
const TAG_ROLLING = "rr"
const TAG_BLOCK_DODGE = "bd"

const SOUND_FALL = 0
const SOUND_DODGE = 1

var EFFECTS_PUNCH_LEFT:AttackEffects = AttackEffects.create(
	AttackEffects.SOUND_PUNCH,
	AttackEffects.ZONE_FIST_LEFT,
	AttackEffects.EFFECT_IMPACT)
var EFFECTS_PUNCH_RIGHT:AttackEffects = AttackEffects.create(
	AttackEffects.SOUND_PUNCH,
	AttackEffects.ZONE_FIST_RIGHT,
	AttackEffects.EFFECT_IMPACT)
var EFFECTS_KICK_LEFT:AttackEffects = AttackEffects.create(
	AttackEffects.SOUND_KICK,
	AttackEffects.ZONE_FOOT_LEFT,
	AttackEffects.EFFECT_IMPACT)
var EFFECTS_KICK_RIGHT:AttackEffects = AttackEffects.create(
	AttackEffects.SOUND_KICK,
	AttackEffects.ZONE_FOOT_RIGHT,
	AttackEffects.EFFECT_IMPACT)
var EFFECTS_NOTHING:AttackEffects = AttackEffects.createEmpty()

const INTENSITY_NORMAL := 0
const INTENSITY_SOFT := 1
const INTENSITY_STRONG := 2

func canUse(_player:CombatMovePlayer) -> bool:
	return true

# Runs only on server
func onEvent(_player:CombatMovePlayer, _eventID:String, _args:Array):
	Log.Print("COMBAT MOVE EVENT! move="+id+" EVENT ID="+_eventID)
	pass

func onStrike(_player:CombatMovePlayer, _attackInfo:AttackInfo, _effects:AttackEffects, _intensity:int):
	_player.doStrike(_attackInfo, _effects, _intensity)

func startMove(_player:CombatMovePlayer):
	consumeConditionTags(_player)
	pushToEffectsQueue(_player, initialEffects.duplicate(true))
	if(!animation.is_empty()):
		_player.pawn.doCombatAnim(animation)
	if(exhaustionOnStart != 0.0):
		_player.causeExhaustion(exhaustionOnStart)

func onCancel(_player:CombatMovePlayer):
	if(cancelEffects.is_empty()):
		return
	pushToEffectsQueue(_player, cancelEffects.duplicate(true))

func pushToEffectsQueue(_player:CombatMovePlayer, _ar:Array):
	_player.pushToEffectsQueue(_ar)

func canUseMoveFinal(_player:CombatMovePlayer) -> bool:
	if(!canCancelExistingMove && _player.isDoingAMove()):
		return false
	if(requiresStamina && _player.isExhausted()):
		return false
	
	for condEntry in conditions:
		var entryType:int = condEntry[0]
		
		if(entryType == COND_TAG):
			if(!_player.hasTag(condEntry[1])):
				return false
		elif(entryType == COND_NO_TAG):
			if(_player.hasTag(condEntry[1])):
				return false
		elif(entryType == COND_JUST_CONSUME):
			continue
		elif(entryType == COND_TAG_ANY):
			var hasAnyTag:bool = false
			for theTag in condEntry[1]:
				if(_player.hasTag(theTag)):
					hasAnyTag = true
					break
			if(!hasAnyTag):
				return false
	
	return canUse(_player)

func consumeConditionTags(_player:CombatMovePlayer):
	for condEntry in conditions:
		var entryType:int = condEntry[0]
		
		if(entryType == COND_TAG):
			_player.eraseTag(condEntry[1])
		if(entryType == COND_TAG_ANY):
			for theTag in condEntry[1]:
				_player.eraseTag(theTag)
		if(entryType == COND_JUST_CONSUME):
			_player.eraseTag(condEntry[1])
