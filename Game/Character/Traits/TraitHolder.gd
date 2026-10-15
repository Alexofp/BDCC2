extends RefCounted
class_name TraitHolder

var charRef:WeakRef
var traits:Dictionary[String, TraitBase]
var cachedList:Array[TraitBase]
var cachedListPassiveRelationshipLoss:Array[TraitBase]
var cachedListSocialExhaustion:Array[TraitBase]
var cachedListRelationshipGainLoss:Array[TraitBase]

signal onTraitsUpdated

func setCharacter(_char:BaseCharacter):
	charRef = weakref(_char) if _char else null

func getCharacter() -> BaseCharacter:
	return charRef.get_ref() if charRef else null

func internal_addTraitToCacheLists(_trait:TraitBase):
	if(_trait.passiveAffectionLossMult != 1.0 || _trait.passiveLustLossMult != 1.0 || _trait.passivePowerBalanceLossMult != 1.0):
		cachedListPassiveRelationshipLoss.append(_trait)
	if(_trait.socialExhaustionGainMult != 1.0 || _trait.socialExhaustionDecayMult != 1.0):
		cachedListSocialExhaustion.append(_trait)
	if(_trait.affectionGainMult != 1.0 || _trait.affectionLossMult != 1.0 || _trait.lustGainMult != 1.0 || _trait.lustLossMult != 1.0 || _trait.powerBalanceGainMult != 1.0 || _trait.powerBalanceLossMult != 1.0):
		cachedListRelationshipGainLoss.append(_trait)

func internal_removeTraitFromCacheLists(_trait:TraitBase):
	cachedListPassiveRelationshipLoss.erase(_trait)
	cachedListSocialExhaustion.erase(_trait)
	cachedListRelationshipGainLoss.erase(_trait)

func internal_clearTraitCacheLists():
	cachedListPassiveRelationshipLoss.clear()
	cachedListSocialExhaustion.clear()
	cachedListRelationshipGainLoss.clear()

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
	
	for _traitID:String in GlobalRegistry.traits:
		if(RNG.chance(50.0)):
			addTrait(_traitID)

	if(false): #TODO: Use this code when the game is gonna have enough traits
		var _allTraits:Dictionary[TraitBase, float] = GlobalRegistry.getTraitScores()
		var _howManyTraits:int = RNG.randiRange(3, 7)
		var _howManyTries:int = 5
		while(_howManyTraits > 0 && _howManyTries > 0):
			var pickedTrait:TraitBase = RNG.pickWeightedDict(_allTraits)
			if(hasTrait(pickedTrait.id) || !canTraitRefBeAdded(pickedTrait)):
				_howManyTries -= 1
				continue
			addTrait(pickedTrait.id)
			_howManyTraits -= 1

func getSocialExhaustionGainMult() -> float:
	var _res:float = 1.0
	for theTrait:TraitBase in cachedListSocialExhaustion:
		_res *= theTrait.socialExhaustionGainMult
	return _res

func getSocialExhaustionDecayMult() -> float:
	var _res:float = 1.0
	for theTrait:TraitBase in cachedListSocialExhaustion:
		_res *= theTrait.socialExhaustionDecayMult
	return _res

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
