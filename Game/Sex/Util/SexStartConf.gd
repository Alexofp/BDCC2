extends RefCounted
class_name SexStartConf

var sexType:String = SexType.OnTheFloor
var roles:Dictionary
var args:Dictionary
var pos:Vector3
var ang:Vector3
var props:Dictionary[String, Node3D]

func addRole(_roleID:String, _charID:String, _role:int = SexRole.Dom) -> SexStartConf:
	roles[_roleID] = {id=_charID, role=_role}
	return self

func addProp(_propID:String, _node:Node3D) -> SexStartConf:
	props[_propID] = _node
	return self
