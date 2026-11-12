extends RefCounted
class_name DollAnimLibMany

var animLibs:Array[DollAnimLib]

#func _init() -> void:
#	registerLibs()

func registerLibs():
	pass

func addAnimLib(_path:String, _alwaysAdd:bool = false):
	var newAnimLib:DollAnimLib = DollAnimLib.new()
	newAnimLib.id = _path.get_file().get_basename()
	newAnimLib.libPath = _path
	newAnimLib.alwaysAdd = _alwaysAdd
	animLibs.append(newAnimLib)
