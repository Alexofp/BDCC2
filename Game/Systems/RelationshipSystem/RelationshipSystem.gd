extends Node
class_name RelationshipSystem

var rareUpdateTimer:float = 0.0
const RARE_UPDATE_TIME := 1.0

var holders:Dictionary[String, RelationshipHolder]
var entries:Array[RelationshipEntry]
var shortTerm:Array[RelationshipShortTermEntry]

func addAffectionRaw(_char1:String, _char2:String, _amount:float):
	var _entry:RelationshipEntry = getOrCreateEntry(_char1, _char2)
	if(!_entry):
		return
	
	_entry.affection += _amount
	_entry.affection = clamp(_entry.affection, -1.0, 1.0)

func addAffection(_char1:String, _char2:String, _amount:float):
	#var currentAffection := getAffection(_char1, _char2)
	#var multiplier := maxf(1.0 - pow(absf(currentAffection), 2.0), 0.05)
	
	Log.Print("Affection change: "+_char1+"  "+_char2+"  "+str(Util.roundF(_amount, 2)))
	addAffectionRaw(_char1, _char2, _amount)#*multiplier)

const AFFECTION_NONLINEAR_POW := 0.5
static func affectionToVisualAffection(_val:float) -> float:
	return pow(_val, AFFECTION_NONLINEAR_POW)

func getAffection(_char1:String, _char2:String) -> float:
	var theEntry := getEntry(_char1, _char2)
	if(!theEntry):
		return 0.0
	return clamp(theEntry.affection, -1.0, 1.0)

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
	
	var holder1 := getOrCreateHolder(_char1)
	holder1.entries[_char2] = newEntry
	var holder2 := getOrCreateHolder(_char2)
	holder2.entries[_char1] = newEntry
	return newEntry

func hasEntry(_char1:String, _char2:String) -> bool:
	return getEntry(_char1, _char2) != null

func knows(_char1:String, _char2:String) -> bool:
	return getEntry(_char1, _char2) != null

func markKnows(_char1:String, _char2:String) -> void:
	getOrCreateEntry(_char1, _char2)

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

func addActionCooldownPawns(_charTarget:CharacterPawn, _charActor:CharacterPawn, _actionID:String, _am:float = 1.0):
	if(!_charTarget || !_charActor):
		return
	addActionCooldown(_charTarget.getCharID(), _charActor.getCharID(), _actionID, _am)

func addActionCooldown(_charTarget:String, _charActor:String, _actionID:String, _am:float = 1.0):
	var theEntry := getOrCreateShortTerm(_charTarget, _charActor)
	if(!theEntry.actionCooldowns.has(_actionID)):
		theEntry.actionCooldowns[_actionID] = _am
	else:
		theEntry.actionCooldowns[_actionID] += _am

func getActionCooldownPawns(_charTarget:CharacterPawn, _charActor:CharacterPawn, _actionID:String) -> float:
	if(!_charTarget || !_charActor):
		return 0.0
	return getActionCooldown(_charTarget.getCharID(), _charActor.getCharID(), _actionID)

func getActionCooldown(_charTarget:String, _charActor:String, _actionID:String) -> float:
	var theEntry := getShortTerm(_charTarget, _charActor)
	if(!theEntry):
		return 0.0
	return theEntry.actionCooldowns.get(_actionID, 0.0)

func _physics_process(_delta: float) -> void:
	var shortAm:int = shortTerm.size()
	for _i in shortAm:
		var _indx:int = shortAm - _i - 1
		
		var entry:RelationshipShortTermEntry = shortTerm[_indx]
		if(entry.updateCheckShouldRemove(_delta)):
			shortTerm.remove_at(_indx)
	
	rareUpdateTimer += _delta
	while(rareUpdateTimer >= RARE_UPDATE_TIME):
		processRare(RARE_UPDATE_TIME)
		rareUpdateTimer -= RARE_UPDATE_TIME
	
func processRare(_dt:float):
	# Relationship decay?
	pass

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
		for theKey in theShortEntry.actionCooldowns:
			theStuff.append(theKey+":"+str(Util.roundF(theShortEntry.actionCooldowns[theKey],2)))
	
	if(theStuff.is_empty()):
		return []
	return [Util.join(theStuff, ",")]
