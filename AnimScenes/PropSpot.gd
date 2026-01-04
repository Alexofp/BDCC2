extends Marker3D
class_name PropSpot

var prop:Node3D
#var propNodePath:NodePath

#signal onPawnSwitch(newPawn)
signal onPropSwitch(newProp:Node3D, oldProp:Node3D)

var propAnimKey:String = ""

func hasProp() -> bool:
	return !!getProp()
	
func getProp() -> Node3D:
	return prop

func setProp(_newProp:Node3D):
	GM.sitManager.setProp(_newProp, self)

func freeSpot():
	GM.sitManager.freePropSpot(self)
#
func _exit_tree() -> void:
	if(GM.sitManager):
		GM.sitManager.handleDeletionOfPropSpot(self)

func onPropChange(_prop:Node3D):
	var oldProp := prop
	prop = _prop
	onPropSwitch.emit(prop, oldProp)
	
