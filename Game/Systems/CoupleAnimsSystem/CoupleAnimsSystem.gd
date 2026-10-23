extends Node
class_name CoupleAnimsSystem

var entries:Array[CoupleAnimEntry]
var pawnToEntry:Dictionary[CharacterPawn, CoupleAnimEntry]

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.Var, saveData(),
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	loadData(_data.readVar())
	_data.endLoad()

func saveData() -> Dictionary:
	var theEntryData:Array[Dictionary]
	for theEntry:CoupleAnimEntry in entries:
		if(theEntry.wasDeleted || theEntry.shouldEndInstantly()):
			continue
		theEntryData.append(theEntry.saveData())
	return {
		entries = theEntryData,
	}

func loadData(_data:Dictionary):
	entries.clear()
	pawnToEntry.clear()
	
	var theEntryData:Array[Dictionary] = SAVE.loadArrayOfDicts(_data, "entries")
	for theEntry:Dictionary in theEntryData:
		var newEntry:CoupleAnimEntry = CoupleAnimEntry.new()
		newEntry.loadData(theEntry)
		if(newEntry.wasDeleted):
			continue
		var theStop := stop.bind(newEntry)
		newEntry.onAnimEnded.connect(theStop)
		newEntry.main.tree_exiting.connect(newEntry.stopMe)
		newEntry.target.tree_exiting.connect(newEntry.stopMe)
		
		entries.append(newEntry)
		pawnToEntry[newEntry.main] = newEntry
		pawnToEntry[newEntry.target] = newEntry

func canStart(_animID:String, _pawnMain:CharacterPawn, _pawnTarget:CharacterPawn) -> bool:
	if(!_pawnMain || !_pawnTarget):
		return false
	if(!_pawnMain.canDoCouplesAnims()):
		return false
	if(!_pawnTarget.canDoCouplesAnims()):
		return false
	var theAnim := GlobalRegistry.getCoupleAnim(_animID)
	if(!theAnim):
		return false
	return true

func isPairDoingAnyAnim(_pawnMain:CharacterPawn, _pawnTarget:CharacterPawn, _biDirectional:bool = true) -> bool:
	if(!_pawnMain || !_pawnTarget):
		return false
	if(!pawnToEntry.has(_pawnMain)):
		return false
	var theEntry:CoupleAnimEntry = pawnToEntry[_pawnMain]
	if(theEntry.main == _pawnMain && theEntry.target == _pawnTarget):
		return true
	if(_biDirectional && theEntry.main == _pawnTarget && theEntry.target == _pawnMain):
		return true
	return false

func isDoingAnyAnim(_pawnMain:CharacterPawn) -> bool:
	if(!_pawnMain):
		return false
	if(!pawnToEntry.has(_pawnMain)):
		return false
	return true

func start(_animID:String, _pawnMain:CharacterPawn, _pawnTarget:CharacterPawn, _infinite:bool = false) -> CoupleAnimEntry:
	if(!canStart(_animID, _pawnMain, _pawnTarget)):
		return null
	var theAnim := GlobalRegistry.getCoupleAnim(_animID)
	
	stopFor(_pawnMain)
	stopFor(_pawnTarget)
	
	var newEntry := CoupleAnimEntry.new()
	newEntry.anim = theAnim
	newEntry.main = _pawnMain
	newEntry.target = _pawnTarget
	newEntry.infTimer = _infinite
	
	var theStop := stop.bind(newEntry)
	newEntry.onAnimEnded.connect(theStop)
	_pawnMain.tree_exiting.connect(newEntry.stopMe)
	_pawnTarget.tree_exiting.connect(newEntry.stopMe)
	
	entries.append(newEntry)
	pawnToEntry[_pawnMain] = newEntry
	pawnToEntry[_pawnTarget] = newEntry
	
	newEntry.onStart()
	
	return newEntry

func stop(_entry:CoupleAnimEntry, _instant:bool = true):
	if(_entry.wasDeleted):
		return
	if(!_instant):
		_entry.shouldEnd = true
		return
	_entry.onEnd()
	_entry.wasDeleted = true
	entries.erase(_entry)
	if(pawnToEntry.has(_entry.main)):
		pawnToEntry.erase(_entry.main)
		_entry.main.tree_exiting.disconnect(_entry.stopMe)
	if(pawnToEntry.has(_entry.target)):
		pawnToEntry.erase(_entry.target)
		_entry.target.tree_exiting.disconnect(_entry.stopMe)

func stopFor(_pawn:CharacterPawn, _instant:bool = true):
	if(!pawnToEntry.has(_pawn)):
		return
	stop(pawnToEntry[_pawn], _instant)

func _process(_delta: float) -> void:
	if(!Network.isServer()):
		return
	var _entryAm:int = entries.size()
	for _i in _entryAm:
		var _indx:int = _entryAm - _i - 1
		var theEntry := entries[_indx]
		theEntry.processAnim(_delta)
