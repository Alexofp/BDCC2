extends RefCounted
class_name TraitHolder

var charRef:WeakRef
var traits:Dictionary[String, TraitBase]
var cachedList:Array[TraitBase]
#var cachedListPassiveRelationshipLoss:Array[TraitBase]
#var cachedListSocialExhaustion:Array[TraitBase]
#var cachedListRelationshipGainLoss:Array[TraitBase]
var cachedTraitsByTraitValue:Dictionary[int, Array] #[int, Array[TraitBase]]

signal onTraitsUpdated

func setCharacter(_char:BaseCharacter):
	charRef = weakref(_char) if _char else null

func getCharacter() -> BaseCharacter:
	return charRef.get_ref() if charRef else null

func getTraitValueMult(_traitValue:int) -> float:
	if(!cachedTraitsByTraitValue.has(_traitValue)):
		return 1.0
	var _res:float = 1.0
	for theTrait:TraitBase in cachedTraitsByTraitValue[_traitValue]:
		_res *= theTrait.values[_traitValue]
	return _res

func getTraitValueSum(_traitValue:int) -> float:
	if(!cachedTraitsByTraitValue.has(_traitValue)):
		return 0.0
	var _res:float = 0.0
	for theTrait:TraitBase in cachedTraitsByTraitValue[_traitValue]:
		_res += theTrait.values[_traitValue]
	return _res

func getTraitValueMax(_traitValue:int, _defValue:float = 0.0) -> float:
	if(!cachedTraitsByTraitValue.has(_traitValue)):
		return _defValue
	var _res:float = _defValue
	for theTrait:TraitBase in cachedTraitsByTraitValue[_traitValue]:
		_res = maxf(_res, theTrait.values[_traitValue])
	return _res

func getTraitValueMin(_traitValue:int, _defValue:float = 999999.9) -> float:
	if(!cachedTraitsByTraitValue.has(_traitValue)):
		return _defValue
	var _res:float = _defValue
	for theTrait:TraitBase in cachedTraitsByTraitValue[_traitValue]:
		_res = minf(_res, theTrait.values[_traitValue])
	return _res

func internal_addTraitToCacheLists(_trait:TraitBase):
	#if(_trait.passiveAffectionLossMult != 1.0 || _trait.passiveLustLossMult != 1.0 || _trait.passivePowerBalanceLossMult != 1.0):
	#	cachedListPassiveRelationshipLoss.append(_trait)
	for _theVal:int in _trait.values:
		if(!cachedTraitsByTraitValue.has(_theVal)):
			var newAr:Array[TraitBase] = [_trait]
			cachedTraitsByTraitValue[_theVal] = newAr
		else:
			cachedTraitsByTraitValue[_theVal].append(_trait)

func internal_removeTraitFromCacheLists(_trait:TraitBase):
	#cachedListPassiveRelationshipLoss.erase(_trait)
	for _theVal:int in _trait.values:
		if(cachedTraitsByTraitValue.has(_theVal)):
			cachedTraitsByTraitValue[_theVal].erase(_trait)
			if(cachedTraitsByTraitValue[_theVal].is_empty()):
				cachedTraitsByTraitValue.erase(_theVal)

func internal_clearTraitCacheLists():
	#cachedListPassiveRelationshipLoss.clear()
	cachedTraitsByTraitValue.clear()

func addTrait(_id:String):
	if(hasTrait(_id)):
		return
	var theTrait:TraitBase = GlobalRegistry.getTrait(_id)
	if(!theTrait || !canTraitRefBeAdded(theTrait)):
		return
	traits[_id] = theTrait
	cachedList.append(theTrait)
	internal_addTraitToCacheLists(theTrait)
	onTraitsUpdated.emit()

func hasTrait(_id:String) -> bool:
	return traits.has(_id)

func removeTrait(_id:String):
	if(!hasTrait(_id)):
		return
	var theTrait:TraitBase = traits[_id]
	traits.erase(_id)
	cachedList.erase(theTrait)
	internal_removeTraitFromCacheLists(theTrait)
	onTraitsUpdated.emit()

func clear(_callSignal:bool = true):
	traits.clear()
	cachedList.clear()
	internal_clearTraitCacheLists()
	if(_callSignal):
		onTraitsUpdated.emit()

func canTraitRefBeAdded(_trait:TraitBase) -> bool:
	if(hasTrait(_trait.id)):
		return false
	if(_trait.compatibilityType.is_empty()):
		return true
	for _ourTrait:TraitBase in cachedList:
		if(_ourTrait.compatibilityType == _trait.compatibilityType):
			return false
	return true

func getTraits() -> Array[TraitBase]:
	return cachedList

func randomizeTraitsGen(_gen:CharacterGenerator):
	randomizeTraits()

func randomizeTraits():
	var _char:BaseCharacter = getCharacter()
	clear(false)
	
	if(true): #TODO: Use this code when the game is gonna have enough traits
		var _allTraits:Dictionary[TraitBase, float] = GlobalRegistry.getTraitScores()
		var _howManyTraits:int = RNG.randiRange(2, 5)
		var _howManyTries:int = 5
		while(_howManyTraits > 0 && _howManyTries > 0):
			var pickedTrait:TraitBase = RNG.pickWeightedDict(_allTraits)
			if(hasTrait(pickedTrait.id) || !canTraitRefBeAdded(pickedTrait)):
				_howManyTries -= 1
				continue
			addTrait(pickedTrait.id)
			_howManyTraits -= 1
		return
	
	for _traitID:String in GlobalRegistry.traits:
		if(RNG.chance(50.0)):
			addTrait(_traitID)

func getSocialExhaustionGainMult() -> float:
	return getTraitValueMult(TraitValue.SocialExhaustionGain)

func getSocialExhaustionDecayMult() -> float:
	return getTraitValueMult(TraitValue.SocialExhaustionDecay)

func saveData() -> Dictionary:
	var _traits:Array[String] = []
	
	for _trait:TraitBase in cachedList:
		_traits.append(_trait.id)
	
	return {
		traits = _traits,
	}

func loadData(_data:Dictionary):
	traits.clear()
	cachedList.clear()
	internal_clearTraitCacheLists()
	
	var _traits:Array = SAVE.loadVar(_data, "traits", [])
	for theTraitID:String in _traits:
		var theTrait:TraitBase = GlobalRegistry.getTrait(theTraitID)
		if(!theTrait):
			continue
		traits[theTraitID] = theTrait
		cachedList.append(theTrait)
		internal_addTraitToCacheLists(theTrait)
	onTraitsUpdated.emit()

func saveNetworkData() -> Bins:
	var Ar:Array = [
		Bins.U16, cachedList.size()
	]
	for _trait:TraitBase in cachedList:
		Ar.append_array([
			Bins.StrShort, _trait.id
		])
	return Bins.saveStartEnd(Ar)

func loadNetworkData(_data:Bins):
	traits.clear()
	cachedList.clear()
	internal_clearTraitCacheLists()
	_data.loadStart()
	var _am:int = _data.readU16()
	for _i:int in _am:
		var theTraitID:String = _data.readStrShort()
		var theTrait:TraitBase = GlobalRegistry.getTrait(theTraitID)
		if(!theTrait):
			continue
		traits[theTraitID] = theTrait
		cachedList.append(theTrait)
		internal_addTraitToCacheLists(theTrait)
	_data.endLoad()
	onTraitsUpdated.emit()
