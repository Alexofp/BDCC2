extends RefCounted
class_name DollAnimEntry

var id:String = ""
var anim:DollAnimBase

# Cached values
var moveSpeed:float = 1.0
var animSpeed:float = 1.0

static func create(_id:String) -> DollAnimEntry:
	var theEntry := DollAnimEntry.new()
	theEntry.setID(_id)
	return theEntry

func setID(_id:String):
	if(_id == id):
		return
	id = _id
	anim = GlobalRegistry.getDollAnim(_id)
	if(anim):
		moveSpeed = anim.getMoveSpeed(_id)
		animSpeed = anim.getAnimSpeed(_id)
	else:
		assert(false, "FAILED TO FIND DOLL ANIM: "+str(_id))
