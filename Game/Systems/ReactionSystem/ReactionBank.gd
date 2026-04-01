extends RefCounted
class_name ReactionBank

var defs:Dictionary[String, ReactionEntry]
var fills:Dictionary[String, Array] # Array of Fills

func reset():
	defs.clear()
	fills.clear()

func merge(_otherBlock:ReactionBank):
	for otherID in _otherBlock.defs:
		defs[otherID] = _otherBlock.defs[otherID]

	for otherID in _otherBlock.fills:
		var theOtherFills:Array[ReactionFill] = _otherBlock.fills[otherID]
		
		if(!fills.has(otherID)):
			fills[otherID] = theOtherFills.duplicate()
		else:
			fills[otherID].append_array(theOtherFills)
