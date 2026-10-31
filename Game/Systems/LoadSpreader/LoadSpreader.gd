extends Node

const BUDGET_DT_SHARE:float = 0.1

var priorityQueue:Array[LoadSpreaderEntry]
#var budgetLeft:float = 0.0

# Add a function!
# func processScheduled(_dt:float, _key:int):
func register(_obj, _howOften:float = 0.05, _key:int = 0):
	var theEntry:LoadSpreaderEntry = LoadSpreaderEntry.new()
	theEntry.obj = weakref(_obj)
	theEntry.howOften = _howOften
	theEntry.key = _key
	insertEntry(theEntry)

# Use binary search?
#func insertEntry(_entry:LoadSpreaderEntry):
#	var theTimeUntil:float = _entry.timeUntil
#	
#	var queueAm:int = priorityQueue.size()
#	for _i:int in queueAm:
#		var theQTimeUntil:float = priorityQueue[_i].timeUntil
#		if(theTimeUntil < theQTimeUntil):
#			priorityQueue.insert(_i, _entry)
#			return
#	priorityQueue.append(_entry)

func insertEntry(_entry: LoadSpreaderEntry) -> void:
	var timeUntil: float = _entry.timeUntil
	var theLow: int = 0
	var theHigh: int = priorityQueue.size()
	while theLow < theHigh:
		var mid: int = (theLow + theHigh) >> 1
		if priorityQueue[mid].timeUntil > timeUntil:
			theHigh = mid
		else:
			theLow = mid + 1
	priorityQueue.insert(theLow, _entry)

func _process(_delta: float) -> void:
	if(priorityQueue.is_empty()):
		return
	var budgetLeft:float = _delta*BUDGET_DT_SHARE
	var _budgetStart:float = budgetLeft
	var didSomething:bool = false
	
	while(budgetLeft > 0.0):
		var theEntry:LoadSpreaderEntry = priorityQueue[0]
		if(theEntry.timeUntil > 0.0):
			break
		if(didSomething && theEntry.howLongTookLastTime > budgetLeft*1.1):
			break
		priorityQueue.pop_front()
		var theObj = theEntry.obj.get_ref()
		if(!theObj):
			continue
		if(theObj is Node):
			if(!theObj.is_inside_tree() || theObj.is_queued_for_deletion()):
				continue
		
		var theStartTicks:int = Time.get_ticks_usec()
		theObj.processScheduled(theEntry.howOften - theEntry.timeUntil, theEntry.key)
		var theEndTicks:int = Time.get_ticks_usec()
		var tookTime:float = (theEndTicks-theStartTicks)/1000000.0

		budgetLeft -= tookTime
		
		theEntry.timeUntil = theEntry.howOften
		theEntry.howLongTookLastTime = theEntry.howLongTookLastTime*0.5 + tookTime*0.5
		insertEntry(theEntry)
		if(tookTime > 0.005):
			didSomething = true
	
	#print(priorityQueue.size()," ",(_budgetStart-budgetLeft)*1000.0)
	
#	var _i:int = 0
	for theEntry:LoadSpreaderEntry in priorityQueue:
		theEntry.timeUntil -= _delta
#		if(_i > 0 && theEntry.howOften > 0.04 && theEntry.timeUntil < -theEntry.howOften): # Protection against death spiraling if things are running too slowly.
#			moveToFront.append(theEntry)
#		_i += 1
#			
#	if(!moveToFront.is_empty()): # Force slow things to update occasionally
#		for theEntry:LoadSpreaderEntry in moveToFront:
#			priorityQueue.erase(theEntry)
#			priorityQueue.push_front(theEntry)
#		moveToFront.clear()
#		
#var moveToFront:Array[LoadSpreaderEntry]
