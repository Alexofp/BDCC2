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
