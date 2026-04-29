extends RefCounted
class_name BuffsHolder

## Holds all of the buff data for the BaseCharacter.

const BOUND_BLINDFOLDED := 1
const BOUND_ARMS := 2
const BOUND_HANDS := 4
const BOUND_LEGS := 8
const BOUND_GAGGED_SPEECH := 16
const BOUND_ORAL_BLOCKED := 32
const BOUND_BITING_BLOCKED := 64
var boundFlags:int = 0 # Contains all of the bondage flags

var supression:float = 0.0 # The higher this value is, the slower the domination ticks down

var painThreshold:float = 0.0 # How much extra pain can you take

func reset():
	boundFlags = 0
	supression = 0.0
	painThreshold = 0.0

var syncState:SyncState = SyncState.new(self,
	["boundFlags", "supression", "painThreshold"],
	[Bins.I32, Bins.Float, Bins.I32],
)
func setSyncVar(_var:String, _val:Variant):
	set(_var, _val)
func getSyncVar(_var:String) -> Variant:
	return get(_var)

var character:BaseCharacter
var updateTime:float = 0.0

func setCharacter(_char:BaseCharacter):
	character = _char

func requestBuffsUpdateDelayed():
	updateTime = 0.0

func requestBuffsUpdateInstant():
	updateBuffs()

func updateBuffs():
	reset()
	
	var theInv:Inventory = character.getInventory()
	for theSlot in theInv.equipped:
		var theItem:ItemBase = theInv.equipped[theSlot]
		var theBuffs := theItem.getBuffs()
		for theBuff in theBuffs:
			theBuff.apply(self)

func processTime(_dt:float):
	updateTime -= _dt
	if(updateTime <= 0.0):
		updateBuffs()
		updateTime = RNG.randfRange(1.0, 2.0)
	
	syncState.processSyncState(_dt)

func isBlind() -> bool:
	return boundFlags & BOUND_BLINDFOLDED

func hasBoundArms() -> bool:
	return boundFlags & BOUND_ARMS

func hasBlockedHands() -> bool:
	return boundFlags & BOUND_HANDS

func hasBoundLegs() -> bool:
	return boundFlags & BOUND_LEGS

func isSpeechGagged() -> bool:
	return boundFlags & BOUND_GAGGED_SPEECH

func isOralBlocked() -> bool:
	return boundFlags & BOUND_ORAL_BLOCKED

func isBitingBlocked() -> bool:
	return boundFlags & BOUND_BITING_BLOCKED

func getSupression() -> float:
	return supression

func getPainExtraThreshold() -> float:
	return painThreshold
