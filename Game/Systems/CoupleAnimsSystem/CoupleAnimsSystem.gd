extends Node
class_name CoupleAnimsSystem

var entries:Array[CoupleAnimEntry]
var pawnToEntry:Dictionary[CharacterPawn, CoupleAnimEntry]

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

func start(_animID:String, _pawnMain:CharacterPawn, _pawnTarget:CharacterPawn) -> CoupleAnimEntry:
	if(!canStart(_animID, _pawnMain, _pawnTarget)):
		return null
	var theAnim := GlobalRegistry.getCoupleAnim(_animID)
	
	stopFor(_pawnMain)
	stopFor(_pawnTarget)
	
	var newEntry := CoupleAnimEntry.new()
	newEntry.anim = theAnim
	newEntry.main = _pawnMain
	newEntry.target = _pawnTarget
	
	var theStop := stop.bind(newEntry)
	newEntry.onAnimEnded.connect(theStop)
	_pawnMain.tree_exiting.connect(newEntry.stopMe)
	_pawnTarget.tree_exiting.connect(newEntry.stopMe)
	
	entries.append(newEntry)
	pawnToEntry[_pawnMain] = newEntry
	pawnToEntry[_pawnTarget] = newEntry
	
	newEntry.onStart()
	
	return newEntry

func stop(_entry:CoupleAnimEntry):
	if(_entry.wasDeleted):
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

func stopFor(_pawn:CharacterPawn):
	if(!pawnToEntry.has(_pawn)):
		return
	stop(pawnToEntry[_pawn])

func _process(_delta: float) -> void:
	if(!Network.isServer()):
		return
	var _entryAm:int = entries.size()
	for _i in _entryAm:
		var _indx:int = _entryAm - _i - 1
		var theEntry := entries[_indx]
		theEntry.processAnim(_delta)
