extends RefCounted
class_name StatusEffectsHolder

signal onEffectsChanged
signal onEffectAdded(_effect:StatusEffectBase)
signal onEffectCombined(_effect:StatusEffectBase)
signal onEffectRemoved(_effect:StatusEffectBase, _holder:StatusEffectsHolder)

var charRef:WeakRef
var effects:Dictionary[String, StatusEffectBase] = {}

func addEffect(_effectID:String, _time:float = -1.0, _args:Array = []):
	if(effects.has(_effectID)):
		var _existingEffect:StatusEffectBase = effects[_effectID]
		_existingEffect.onCombine(_time, _args)
		onEffectCombined.emit(_existingEffect)
		return
	var theEffect:StatusEffectBase = GlobalRegistry.createStatusEffect(_effectID)
	if(!theEffect):
		return
	theEffect.time = _time if _time >= 0.0 else theEffect.defaultTime
	theEffect.setEffectsHolder(self)
	theEffect.onStart(_args)
	effects[_effectID] = theEffect
	onEffectAdded.emit(theEffect)
	onEffectsChanged.emit()

func addEffectFromBinsData(_effectID:String, _data:Bins, _isCombine:bool = false):
	var theEffect:StatusEffectBase = GlobalRegistry.createStatusEffect(_effectID)
	if(!theEffect):
		return
	theEffect.setEffectsHolder(self)
	effects[_effectID] = theEffect
	theEffect.loadNetworkData(_data)
	if(!_isCombine):
		onEffectAdded.emit(theEffect)
	else:
		onEffectCombined.emit(theEffect)
	onEffectsChanged.emit()

func hasEffect(_effectID:String) -> bool:
	return effects.has(_effectID)

func getEffect(_effectID:String) -> StatusEffectBase:
	if(!effects.has(_effectID)):
		return null
	return effects[_effectID]

func removeEffect(_effectID:String):
	if(!hasEffect(_effectID)):
		return
	var theEffect:StatusEffectBase = effects[_effectID]
	if(!theEffect):
		return
	effects.erase(_effectID)
	onEffectRemoved.emit(theEffect, self)
	onEffectsChanged.emit()

var internalToRemove:Array[String]
func processTime(_dt:float):
	var _theChar:BaseCharacter = getChar()
	if(!_theChar):
		return
	
	for theEffect:StatusEffectBase in GlobalRegistry.statusEffectsAlwaysChecked:
		if(theEffect.shouldApplyTo(_theChar)):
			if(!hasEffect(theEffect.id)): # To avoid combining stuff every time
				addEffect(theEffect.id)
		else:
			removeEffect(theEffect.id) # Remove checks if the effect exists
	
	for theID:String in effects:
		var theEffect:StatusEffectBase = effects[theID]
		if(!theEffect.timed): # .isTimed() would be more flexible but slower?
			continue
		theEffect.time -= _dt
		if(theEffect.time <= 0.0):
			theEffect.shouldBeRemoved = true
			internalToRemove.append(theID)
		elif(theEffect.shouldBeRemoved):
			internalToRemove.append(theID)
	
	if(Network.isServer()): # Only server can actually delete effects, clients just tick their timers down
		for theID:String in internalToRemove:
			var theEffect:StatusEffectBase = effects.get(theID)
			effects.erase(theID)
			if(theEffect):
				onEffectRemoved.emit(theEffect, self)
		if(!internalToRemove.is_empty()):
			onEffectsChanged.emit()
	internalToRemove.clear()

func setCharacter(_char:BaseCharacter):
	charRef = weakref(_char)

func getCharacter() -> BaseCharacter:
	if(!charRef):
		return null
	return charRef.get_ref()

func getChar() -> BaseCharacter:
	if(!charRef):
		return null
	return charRef.get_ref()

func saveData() -> Dictionary:
	var effectsData:Array[Dictionary] = []
	
	for theEffectID:String in effects:
		var theEffect:StatusEffectBase = effects[theEffectID]
		effectsData.append({
			id = theEffectID,
			data = theEffect.saveData(),
		})
	return {
		effects = effectsData,
	}

func loadData(_data:Dictionary):
	effects.clear()
	
	var _effectsData:Array = SAVE.loadVar(_data, "effects", [])
	for theEntry:Dictionary in _effectsData:
		var theID:String = SAVE.loadVar(theEntry, "id", "")
		if(theID.is_empty()):
			continue
		var theEffect:StatusEffectBase = GlobalRegistry.createStatusEffect(theID)
		if(!theEffect):
			continue
		theEffect.setEffectsHolder(self)
		effects[theID] = theEffect
		theEffect.loadData(SAVE.loadVar(theEntry, "data", {}))
	
	onEffectsChanged.emit()

func saveNetworkData() -> Bins:
	var theAr:Array = [
		Bins.U16, effects.size(),
	]
	for theEffectID:String in effects:
		var theEffect:StatusEffectBase = effects[theEffectID]
		theAr.append_array([
			Bins.StrShort, theEffectID,
			Bins.BINS, theEffect.saveNetworkData()
		])
	return Bins.saveStartEnd(theAr)

func loadNetworkData(_bins:Bins):
	_bins.loadStart()
	var _effectAm:int = _bins.readU16()
	effects.clear()
	
	for _i in _effectAm:
		var theID:String = _bins.readStrShort()
		var theBins:Bins = _bins.readBins()
		
		if(theID.is_empty()):
			continue
		var theEffect:StatusEffectBase = GlobalRegistry.createStatusEffect(theID)
		if(!theEffect):
			continue
		theEffect.setEffectsHolder(self)
		effects[theID] = theEffect
		theEffect.loadNetworkData(theBins)
		
	_bins.endLoad()
	
	onEffectsChanged.emit()
