extends Node
class_name RelationshipSystem

var rareUpdateTimer:float = 0.0
var veryRareUpdateTimer:float = 0.0
const RARE_UPDATE_TIME := 10.0
const VERY_RARE_UPDATE_TIME := 60.0

var holders:Dictionary[String, RelationshipHolder]
var entries:Array[RelationshipEntry]
var shortTerm:Array[RelationshipShortTermEntry]

var toSyncEntries:Dictionary[RelationshipEntry, bool]

func markToSync(_entry:RelationshipEntry):
	if(Network.isServerNotSingleplayer()):
		toSyncEntries[_entry] = true

func scaleAddValue(_valAdd:float, _currValue:float) -> float:
	if(_currValue > 0.0 && _valAdd > 0.0):
		_valAdd /= (_currValue+1.0)
	if(_currValue < -0.0 && _valAdd < 0.0):
		_valAdd /= (-_currValue+1.0)
	return _valAdd

func setAffection(_char1:String, _char2:String, _amount:float):
	var _entry:RelationshipEntry = getOrCreateEntry(_char1, _char2)
	if(!_entry):
		return
	var _oldAffection:float = _entry.affection
	_entry.affection = clamp(_amount, RSValue.AFFECTION_MIN, RSValue.AFFECTION_MAX)
	if(_oldAffection != _entry.affection):
		markToSync(_entry)

func addAffectionRaw(_char1:String, _char2:String, _amount:float):
	var _entry:RelationshipEntry = getOrCreateEntry(_char1, _char2)
	if(!_entry):
		return
	setAffection(_char1, _char2, _entry.affection + _amount)

func setLust(_char1:String, _char2:String, _amount:float):
	var _entry:RelationshipEntry = getOrCreateEntry(_char1, _char2)
	if(!_entry):
		return
	var _oldValue:float = _entry.lust
	_entry.lust = clamp(_amount, RSValue.LUST_MIN, RSValue.LUST_MAX)
	if(_oldValue != _entry.lust):
		markToSync(_entry)

func addLustRaw(_char1:String, _char2:String, _amount:float):
	var _entry:RelationshipEntry = getOrCreateEntry(_char1, _char2)
	if(!_entry):
		return
	setLust(_char1, _char2, _entry.lust + _amount)

func setPowerBalance(_char1:String, _char2:String, _amount:float):
	var _entry:RelationshipEntry = getOrCreateEntry(_char1, _char2)
	if(!_entry):
		return
	var _oldValue:float = _entry.powerBalance
	if(_char1 == _entry.char1):
		_entry.powerBalance = clamp(_amount, -RSValue.POWERBALANCE_LIMIT, RSValue.POWERBALANCE_LIMIT)
	else:
		_entry.powerBalance = clamp(-_amount, -RSValue.POWERBALANCE_LIMIT, RSValue.POWERBALANCE_LIMIT)
	if(_oldValue != _entry.powerBalance):
		markToSync(_entry)

func addPowerBalanceRaw(_char1:String, _char2:String, _amount:float):
	var _entry:RelationshipEntry = getOrCreateEntry(_char1, _char2)
	if(!_entry):
		return
	if(_char1 == _entry.char1):
		setPowerBalance(_char1, _char2, _entry.powerBalance + _amount)
	else:
		setPowerBalance(_char1, _char2, -_entry.powerBalance + _amount)

func addAffection(_char1:String, _char2:String, _amount:float):
	var currentAffection := getAffection(_char1, _char2)
	
	_amount = scaleAddValue(_amount, currentAffection)
	
	var _trait1:TraitHolder = getTraitHolder(_char1)
	var _trait2:TraitHolder = getTraitHolder(_char2)
	if(_trait1 && _trait2):
		if(_amount > 0.0):
			for theTrait:TraitBase in _trait1.cachedListRelationshipGainLoss:
				_amount *= theTrait.affectionGainMult
			for theTrait:TraitBase in _trait2.cachedListRelationshipGainLoss:
				_amount *= theTrait.affectionGainMult
		if(_amount < 0.0):
			for theTrait:TraitBase in _trait1.cachedListRelationshipGainLoss:
				_amount *= theTrait.affectionLossMult
			for theTrait:TraitBase in _trait2.cachedListRelationshipGainLoss:
				_amount *= theTrait.affectionLossMult
	
	#var multiplier := maxf(1.0 - pow(absf(currentAffection), 2.0), 0.05)
	Log.Print("Affection change: "+_char1+"  "+_char2+"  "+str(Util.roundF(_amount, 2)))
	addAffectionRaw(_char1, _char2, _amount)#*multiplier)

func addLust(_char1:String, _char2:String, _amount:float):
	var curValue := getLust(_char1, _char2)
	
	_amount = scaleAddValue(_amount, curValue)
	
	var _trait1:TraitHolder = getTraitHolder(_char1)
	var _trait2:TraitHolder = getTraitHolder(_char2)
	if(_trait1 && _trait2):
		if(_amount > 0.0):
			for theTrait:TraitBase in _trait1.cachedListRelationshipGainLoss:
				_amount *= theTrait.lustGainMult
			for theTrait:TraitBase in _trait2.cachedListRelationshipGainLoss:
				_amount *= theTrait.lustGainMult
		if(_amount < 0.0):
			for theTrait:TraitBase in _trait1.cachedListRelationshipGainLoss:
				_amount *= theTrait.lustLossMult
			for theTrait:TraitBase in _trait2.cachedListRelationshipGainLoss:
				_amount *= theTrait.lustLossMult
	
	Log.Print("Lust change: "+_char1+"  "+_char2+"  "+str(Util.roundF(_amount, 2)))
	addLustRaw(_char1, _char2, _amount)#*multiplier)

func addPowerBalance(_char1:String, _char2:String, _amount:float):
	var curValue := getPowerBalance(_char1, _char2)
	
	_amount = scaleAddValue(_amount, curValue)
	
	var _trait1:TraitHolder = getTraitHolder(_char1)
	var _trait2:TraitHolder = getTraitHolder(_char2)
	if(_trait1 && _trait2):
		if(_amount > 0.0):
			for theTrait:TraitBase in _trait1.cachedListRelationshipGainLoss:
				_amount *= theTrait.powerBalanceGainMult
			for theTrait:TraitBase in _trait2.cachedListRelationshipGainLoss:
				_amount *= theTrait.powerBalanceLossMult
		if(_amount < 0.0):
			for theTrait:TraitBase in _trait1.cachedListRelationshipGainLoss:
				_amount *= theTrait.powerBalanceLossMult
			for theTrait:TraitBase in _trait2.cachedListRelationshipGainLoss:
				_amount *= theTrait.powerBalanceGainMult
	
	Log.Print("Power balance change: "+_char1+"  "+_char2+"  "+str(Util.roundF(_amount, 2)))
	addPowerBalanceRaw(_char1, _char2, _amount)

func getAffection(_char1:String, _char2:String) -> float:
	var theEntry := getEntry(_char1, _char2)
	if(!theEntry):
		return 0.0
	return clamp(theEntry.affection, RSValue.AFFECTION_MIN, RSValue.AFFECTION_MAX)

func getLust(_char1:String, _char2:String) -> float:
	var theEntry := getEntry(_char1, _char2)
	if(!theEntry):
		return 0.0
	return clamp(theEntry.lust, RSValue.LUST_MIN, RSValue.LUST_MAX)

# Asymmetrical value!
# 1.0 = _charFrom dominates _charTo
# -1.0 = _charFrom is dominated by _charTo
func getPowerBalance(_charFrom:String, _charTo:String) -> float:
	var theEntry := getEntry(_charFrom, _charTo)
	if(!theEntry):
		return 0.0
	return clamp(theEntry.powerBalance if theEntry.char1 == _charFrom else (-theEntry.powerBalance), -RSValue.POWERBALANCE_LIMIT, RSValue.POWERBALANCE_LIMIT)

func getOrCreateHolder(_charID:String) -> RelationshipHolder:
	if(!GM.main.characterRegistry.hasCharacter(_charID)):
		Log.Printerr("Trying to create a RelationshipHolder for a missing character ID: "+str(_charID))
		return null
	if(holders.has(_charID)):
		return holders[_charID]
	var newHolder:RelationshipHolder = RelationshipHolder.new()
	holders[_charID] = newHolder
	return newHolder

func createEntry(_char1:String, _char2:String) -> RelationshipEntry:
	if(!GM.main.characterRegistry.hasCharacter(_char1)):
		Log.Printerr("Trying to create a RelationshipHolder for a missing character ID: "+str(_char1))
		return null
	if(!GM.main.characterRegistry.hasCharacter(_char2)):
		Log.Printerr("Trying to create a RelationshipHolder for a missing character ID: "+str(_char2))
		return null
	var newEntry:RelationshipEntry = RelationshipEntry.new()
	newEntry.char1 = _char1
	newEntry.char2 = _char2
	
	assignEntry(newEntry)
	return newEntry

# Must only be called if we're certain that there isn't an entry already. Otherwise stuff will break
func assignEntry(newEntry:RelationshipEntry):
	entries.append(newEntry)
	if(Network.isServerNotSingleplayer()):
		toSyncEntries[newEntry] = true
	
	var holder1 := getOrCreateHolder(newEntry.char1)
	holder1.entries[newEntry.char2] = newEntry
	var holder2 := getOrCreateHolder(newEntry.char2)
	holder2.entries[newEntry.char1] = newEntry

func getHolder(_charID:String) -> RelationshipHolder:
	return holders[_charID] if holders.has(_charID) else null

func deleteEntry(_entry:RelationshipEntry, _forgetIntroduced:bool = true) -> bool:
	var holder1 := getHolder(_entry.char1)
	var holder2 := getHolder(_entry.char2)
	if(!holder1 && !holder2):
		return false
	
	if(holder1):
		holder1.entries.erase(_entry.char2)
		if(_forgetIntroduced):
			holder1.introduced.erase(_entry.char2)
	if(holder2):
		holder2.entries.erase(_entry.char1)
		if(_forgetIntroduced):
			holder2.introduced.erase(_entry.char1)
	entries.erase(_entry)
	toSyncEntries.erase(_entry)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(deleteEntry_RPC.bind(_entry.char1, _entry.char2, _forgetIntroduced))
	return true

@rpc("call_remote", "authority", "reliable")
func deleteEntry_RPC(_char1:String, _char2:String, _forgetIntroduced:bool = true):
	deleteEntryBetween(_char1, _char2, _forgetIntroduced)

func deleteEntryBetween(_char1:String, _char2:String, _forgetIntroduced:bool = true) -> bool:
	var theEntry := getEntry(_char1, _char2)
	if(!theEntry):
		return false
	return deleteEntry(theEntry, _forgetIntroduced)

func deleteAllEntriesOf(_charID:String):
	var toRem:Array[RelationshipEntry] = []
	var theHolder := getHolder(_charID)
	if(!theHolder):
		return
	for theOtherCharID in theHolder.entries:
		toRem.append(theHolder.entries[theOtherCharID])
	for theEntry in toRem:
		deleteEntry(theEntry)

func deleteHolderOf(_charID:String):
	deleteAllEntriesOf(_charID)
	holders.erase(_charID)
	if(Network.isServerNotSingleplayer()):
		Network.rpcClients(deleteHolderOf_RPC.bind(_charID))

@rpc("call_remote", "authority", "reliable")
func deleteHolderOf_RPC(_charID:String):
	deleteAllEntriesOf(_charID)
	holders.erase(_charID)

func onCharacterIDRemoved(_charID:String):
	if(Network.isServer()):
		deleteHolderOf(_charID)
		removeAllShortTermsOf(_charID)

func hasEntry(_char1:String, _char2:String) -> bool:
	return getEntry(_char1, _char2) != null

func knows(_char1:String, _char2:String) -> bool:
	var theHolder := getHolder(_char1)
	if(!theHolder):
		return false
	return theHolder.introduced.has(_char2)

func markKnows(_char1:String, _char2:String) -> void:
	var theHolder := getOrCreateHolder(_char1)
	if(!theHolder):
		return
	theHolder.introduced[_char2] = true

func getEntry(_char1:String, _char2:String) -> RelationshipEntry:
	if(!holders.has(_char1)):
		return null
	var theHolder:RelationshipHolder = holders[_char1]
	if(!theHolder.entries.has(_char2)):
		return null
	return theHolder.entries.get(_char2, null)

func getOrCreateEntry(_char1:String, _char2:String) -> RelationshipEntry:
	var theEntry := getEntry(_char1, _char2)
	if(theEntry):
		return theEntry
	return createEntry(_char1, _char2)

func getShortTerm(_charReactor:String, _charTarget:String) -> RelationshipShortTermEntry:
	for entry in shortTerm:
		if(entry.char1 == _charReactor && entry.char2 == _charTarget):
			return entry
	return null

func getOrCreateShortTerm(_charReactor:String, _charTarget:String) -> RelationshipShortTermEntry:
	for entry in shortTerm:
		if(entry.char1 == _charReactor && entry.char2 == _charTarget):
			return entry
	var newShortTerm:RelationshipShortTermEntry = RelationshipShortTermEntry.new()
	newShortTerm.char1 = _charReactor
	newShortTerm.char2 = _charTarget
	shortTerm.append(newShortTerm)
	return newShortTerm

func removeAllShortTermsOf(_charID:String):
	var shortAm:int = shortTerm.size()
	for _i in shortAm:
		var _indx:int = shortAm - _i - 1
		var theEntry:RelationshipShortTermEntry = shortTerm[_indx]
		if(theEntry.char1 == _charID || theEntry.char2):
			shortTerm.remove_at(_indx)
	#var toRem:Array[RelationshipShortTermEntry] = []
	#for theEntry in shortTerm:
		#if(theEntry.char1 == _charID || theEntry.char2):
			#toRem.append(theEntry)
	#for theEntry in toRem:
		#shortTerm.erase(theEntry)

func addAnnoyancePawns(_pawnAnnoyed:CharacterPawn, _pawnWhoIsAnnoying:CharacterPawn, _howMuch:float):
	if(!_pawnAnnoyed || !_pawnWhoIsAnnoying):
		return
	addAnnoyance(_pawnAnnoyed.getCharID(), _pawnWhoIsAnnoying.getCharID(), _howMuch)
	
func addAnnoyance(_charAnnoyed:String, _charWhoIsAnnoying:String, _howMuch:float):
	Log.Print("ADDING ANNOY: "+str(_charAnnoyed)+" "+str(_charWhoIsAnnoying)+" "+str(_howMuch))
	
	var theEntry := getOrCreateShortTerm(_charAnnoyed, _charWhoIsAnnoying)
	if(theEntry):
		theEntry.annoyed += _howMuch
		return

# Somewhat slow method, don't use every frame
func getAnnoyancePawns(_pawnAnnoyed:CharacterPawn, _pawnWhoIsAnnoying:CharacterPawn) -> float:
	if(!_pawnAnnoyed || !_pawnWhoIsAnnoying):
		return 0.0
	return getAnnoyance(_pawnAnnoyed.getCharID(), _pawnWhoIsAnnoying.getCharID())

# Somewhat slow method, don't use every frame
func getAnnoyance(_charAnnoyed:String, _charWhoIsAnnoying:String) -> float:
	var theEntry := getShortTerm(_charAnnoyed, _charWhoIsAnnoying)
	if(!theEntry):
		return 0.0
	return theEntry.annoyed

func addActionCooldownPawns(_charTarget:CharacterPawn, _charActor:CharacterPawn, _actionID:String, _seconds:float, _add:bool = true):
	if(!_charTarget || !_charActor):
		return
	_charTarget.cooldowns.addCharIDCooldown(_charActor.getCharID(), _actionID, _seconds, _add)

func addActionCooldown(_charTarget:String, _charActor:String, _actionID:String, _seconds:float, _add:bool = true):
	var thePawn:CharacterPawn = GM.pawnRegistry.getPawn(_charTarget)
	if(!thePawn):
		return
	thePawn.cooldowns.addCharIDCooldown(_charActor, _actionID, _seconds, _add)

func getActionCooldownPawns(_charTarget:CharacterPawn, _charActor:CharacterPawn, _actionID:String) -> float:
	if(!_charTarget || !_charActor):
		return 0.0
	return _charTarget.cooldowns.getCharIDCooldown(_charActor.getCharID(), _actionID)

func getActionCooldown(_charTarget:String, _charActor:String, _actionID:String) -> float:
	var thePawn:CharacterPawn = GM.pawnRegistry.getPawn(_charTarget)
	if(!thePawn):
		return 0.0
	return thePawn.cooldowns.getCharIDCooldown(_charActor, _actionID)

var rareUpdateI:int = 0

func _physics_process(_delta: float) -> void:
	var shortAm:int = shortTerm.size()
	if(!shortTerm.is_empty()):
		rareUpdateTimer += _delta
		var theRareTime:float = RARE_UPDATE_TIME / float(shortAm)
		while(rareUpdateTimer >= theRareTime && !shortTerm.is_empty()):
			if(rareUpdateI < 0 || rareUpdateI >= shortTerm.size()):
				rareUpdateI = 0
			#print("UPDATE: ",rareUpdateI)
			
			rareUpdateTimer -= theRareTime
			var entry:RelationshipShortTermEntry = shortTerm[rareUpdateI]
			if(entry.updateCheckShouldRemove(RARE_UPDATE_TIME)):
				shortTerm.remove_at(rareUpdateI)
				Log.Print("REMOVED SHORT TERM: "+entry.char1+" "+entry.char2)
			else:
				rareUpdateI += 1
	
	veryRareUpdateTimer += _delta
	while(veryRareUpdateTimer >= VERY_RARE_UPDATE_TIME):
		processVeryRare(VERY_RARE_UPDATE_TIME)
		veryRareUpdateTimer -= VERY_RARE_UPDATE_TIME
	
	if(!toSyncEntries.is_empty()):
		if(Network.isServerNotSingleplayer()):
			var theAr:Array = [
				Bins.I32, toSyncEntries.size(),
			]
			for theEntry:RelationshipEntry in toSyncEntries:
				theAr.append_array([
					Bins.BINS, theEntry.saveNetworkData(),
				])
			var theCombinedData:Bins = Bins.saveStartEnd(theAr)
			Network.rpcClients(applyRelationshipSyncData_RPC.bind(theCombinedData.getBytesCompressedSimple()))
		toSyncEntries.clear()
			
@rpc("call_remote", "authority", "reliable")
func applyRelationshipSyncData_RPC(_data:PackedByteArray):
	var _bins:Bins = Bins.readCompressedSimple(_data)
	_bins.loadStart()
	var _am:int = _bins.readI32()
	for _i in _am:
		var theEntry:RelationshipEntry = RelationshipEntry.new()
		theEntry.loadNetworkData(_bins.readBins())
		
		var theExistingEntry := getEntry(theEntry.char1, theEntry.char2)
		if(theExistingEntry):
			theExistingEntry.copyFrom(theEntry)
		else:
			assignEntry(theEntry)
	_bins.endLoad()

# Happens every minute
func processVeryRare(_dt:float):
	var toRem:Array[RelationshipEntry] = []
	# Relationship decay?
	# Spread the decay over different calls?
	# Can update just a few holders
	for theEntry:RelationshipEntry in entries:
		if(theEntry.decayEntryShouldRemove(_dt)):
			toRem.append(theEntry)
	
	for theEntry in toRem:
		deleteEntry(theEntry)
			

func getDebugTextLinesFor(_pawn:CharacterPawn) -> Array[String]:
	var theStuff:Array[String] = []
	
	var thePCPawn := GM.pcPawn
	if(thePCPawn == _pawn):
		return []
	
	var theEntry := getEntry(_pawn.getCharID(), thePCPawn.getCharID())
	if(theEntry):
		theStuff.append("Aff:"+str(Util.roundF(theEntry.affection,2)))
	
	var theShortEntry := getShortTerm(_pawn.getCharID(), thePCPawn.getCharID())
	if(theShortEntry):
		if(theShortEntry.annoyed > 0.0):
			theStuff.append("Annoy:"+str(Util.roundF(theShortEntry.annoyed,2)))
		#for theKey in theShortEntry.actionCooldowns:
		#	theStuff.append(theKey+":"+str(Util.roundF(theShortEntry.actionCooldowns[theKey],2)))

	if(theStuff.is_empty()):
		return []
	return [Util.join(theStuff, ",")]

func getTraitHolder(_charID:String) -> TraitHolder:
	var theChar:BaseCharacter = GM.characterRegistry.getCharacter(_charID)
	if(!theChar):
		return null
	return theChar.traitHolder

func saveNetworkData() -> Bins:
	var Ar:Array = [
		Bins.I32, entries.size(),
	]
	for theEntry:RelationshipEntry in entries:
		Ar.append_array([
			Bins.BINS, theEntry.saveNetworkData(),
		])
	
	return Bins.saveStartEnd(Ar)

func loadNetworkData(_data:Bins):
	holders.clear()
	entries.clear()
	_data.loadStart()
	var _am:int = _data.readI32()
	
	for _i in _am:
		var theEntry := RelationshipEntry.new()
		theEntry.loadNetworkData(_data.readBins())
		assignEntry(theEntry)

	_data.endLoad()

func saveData() -> Dictionary: #TODO: Make me work
	return {}

func loadData(_data:Dictionary):
	pass
