extends Node
class_name RelationshipSystem

var rareUpdateTimer:float = 0.0
const RARE_UPDATE_TIME := 1.0

var holders:Dictionary[String, RelationshipHolder]
var entries:Array[RelationshipEntry]
var shortTerm:Array[RelationshipShortTermEntry]

func getOrCreateHolder(_charID:String) -> RelationshipHolder:
	if(holders.has(_charID)):
		return holders[_charID]
	var newHolder:RelationshipHolder = RelationshipHolder.new()
	holders[_charID] = newHolder
	return newHolder

func createEntry(_char1:String, _char2:String) -> RelationshipEntry:
	var newEntry:RelationshipEntry = RelationshipEntry.new()
	newEntry.char1 = _char1
	newEntry.char2 = _char2
	
	var holder1 := getOrCreateHolder(_char1)
	holder1.entries[_char2] = newEntry
	var holder2 := getOrCreateHolder(_char2)
	holder2.entries[_char1] = newEntry
	return newEntry

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

func addAnnoyance(_charAnnoyed:String, _charWhoIsAnnoying:String, _howMuch:float):
	Log.Print("ADDING ANNOY: "+str(_charAnnoyed)+" "+str(_charWhoIsAnnoying)+" "+str(_howMuch))
	
	var theEntry := getShortTerm(_charAnnoyed, _charWhoIsAnnoying)
	if(theEntry):
		theEntry.annoyed += _howMuch
		return
	
	var newShortTerm:RelationshipShortTermEntry = RelationshipShortTermEntry.new()
	newShortTerm.char1 = _charAnnoyed
	newShortTerm.char2 = _charWhoIsAnnoying
	newShortTerm.annoyed = _howMuch
	shortTerm.append(newShortTerm)

# Somewhat slow method, don't use every frame
func getAnnoyance(_charAnnoyed:String, _charWhoIsAnnoying:String) -> float:
	var theEntry := getShortTerm(_charAnnoyed, _charWhoIsAnnoying)
	if(!theEntry):
		return 0.0
	return theEntry.annoyed

func _physics_process(_delta: float) -> void:
	var shortAm:int = shortTerm.size()
	for _i in shortAm:
		var _indx:int = shortAm - _i - 1
		
		var entry:RelationshipShortTermEntry = shortTerm[_indx]
		
		entry.annoyed -= _delta*0.1 # Should depend on personality?
		
		if(entry.canBeRemoved()):
			shortTerm.remove_at(_indx)
	
	rareUpdateTimer += _delta
	while(rareUpdateTimer >= RARE_UPDATE_TIME):
		processRare(RARE_UPDATE_TIME)
		rareUpdateTimer -= RARE_UPDATE_TIME
	
func processRare(_dt:float):
	# Relationship decay?
	pass
