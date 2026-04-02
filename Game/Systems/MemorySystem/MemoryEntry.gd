extends RefCounted
class_name MemoryEntry

var memory:MemoryBase
var happenedAt:int = 0 # Global seconds
var willExpireAt:int = 0 # Global seconds
var noEffectsAfter:int = 0 # Global seconds

#var args:Dictionary
var otherPawnID:String
#var targetID:String
#var stacks:int = 0
#var success:float = 0.0 # a number from -1.0 to 1.0

func getProgress() -> float:
	var theCurrentTime := GM.main.timeManager.getTimeFull()
	var secondsPassed:int = theCurrentTime - happenedAt
	var totalDuration:int = noEffectsAfter - happenedAt
	return clampf(remap(float(secondsPassed), 0.0, float(totalDuration), 0.0, 1.0), 0.0, 1.0)

func calculateFinalPriority() -> float:
	return getProgress() * memory.priority

## How many seconds have passed since this memory was added
func getElapsedSeconds() -> int:
	return GM.main.timeManager.getTimeFull() - happenedAt

## What day did this memory happened at
func getDay() -> int:
	return TimeManager.getDayAt(happenedAt)

## How many days ago was this memory
func getElapsedDays() -> int:
	var startDay:int = TimeManager.getDayAt(happenedAt)
	var currentDay:int = GM.main.timeManager.day
	return currentDay - startDay
