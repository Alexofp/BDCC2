extends RefCounted
class_name PawnCooldowns

const FriendlyInteraction:String = "intFr"
const MeanInteraction:String = "intMean"
const HelpfulInteraction:String = "intHelp"

var cooldowns:Dictionary[String, float]
var charCooldowns:Dictionary[String, float]

func addCooldown(_id:String, _seconds:float, _add:bool = true):
	if(_add && cooldowns.has(_id)):
		cooldowns[_id] += _seconds
	else:
		cooldowns[_id] = _seconds

func getCooldown(_id:String) -> float:
	if(!cooldowns.has(_id)):
		return 0.0
	return cooldowns[_id]

func hasCooldown(_id:String) -> bool:
	return cooldowns.has(_id)

var toRem:Array[String]
var toRem2:Array[String]
func processCooldowns(_dt:float):
	toRem.clear()
	toRem2.clear()
	
	for _id:String in cooldowns:
		cooldowns[_id] -= _dt
		if(cooldowns[_id] <= 0.0):
			toRem.append(_id)
	for _id:String in toRem:
		cooldowns.erase(_id)
	
	for _id:String in charCooldowns:
		charCooldowns[_id] -= _dt * GM.GB.socialCooldownDecayRate#ACTION_COOLDOWN_DECAY_RATE
		if(charCooldowns[_id] <= 0.0):
			toRem2.append(_id)
	for _id:String in toRem2:
		charCooldowns.erase(_id)

const CharConnector:String = "="
func addCharIDCooldown(_charID:String, _actionID:String, _seconds:float, _add:bool = true):
	var theID:String = _charID+CharConnector+_actionID
	if(_add && charCooldowns.has(theID)):
		charCooldowns[theID] += _seconds
	else:
		charCooldowns[theID] = _seconds

func getCharIDCooldown(_charID:String, _actionID:String) -> float:
	var theID:String = _charID+CharConnector+_actionID
	if(!charCooldowns.has(theID)):
		return 0.0
	return charCooldowns[theID]

func hasCharIDCooldown(_charID:String, _actionID:String) -> bool:
	var theID:String = _charID+CharConnector+_actionID
	if(!charCooldowns.has(theID)):
		return false
	return true

func saveData() -> Dictionary:
	return {
		cds = cooldowns,
		ccs = charCooldowns,
	}

func loadData(_data:Dictionary):
	cooldowns = SAVE.loadVar(_data, "cds", {})
	charCooldowns = SAVE.loadVar(_data, "ccs", {})

func saveNetworkData() -> Bins:
	var ar:Array = [
		Bins.U16, cooldowns.size(),
		Bins.U16, charCooldowns.size(),
	]
	for _id:String in cooldowns:
		var theCD:float = cooldowns[_id]
		ar.append_array([
			Bins.StrShort, _id,
			Bins.Float, theCD,
		])
	for _id:String in charCooldowns:
		var theCD:float = charCooldowns[_id]
		ar.append_array([
			Bins.StrShort, _id,
			Bins.Float, theCD,
		])
	return Bins.saveStartEnd(ar)

func loadNetworkData(_data:Bins):
	_data.loadStart()
	cooldowns.clear()
	charCooldowns.clear()
	var _am:int = _data.readU16()
	var _am2:int = _data.readU16()
	for _i:int in _am:
		var _id:String = _data.readStrShort()
		var _cdAm:float = _data.readFloat()
		cooldowns[_id] = _cdAm
	for _i:int in _am2:
		var _id:String = _data.readStrShort()
		var _cdAm:float = _data.readFloat()
		charCooldowns[_id] = _cdAm
	_data.endLoad()
