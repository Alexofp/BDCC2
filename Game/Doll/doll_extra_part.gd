extends DollBasePart
class_name DollExtraPart

var dollPartRef:WeakRef

func _enter_tree() -> void:
	if(get_parent() is Skeleton3D):
		var theSkeleton:Skeleton3D = get_parent()
		for mesh in getMeshes():
			if(mesh is MeshInstance3D):
				#if(!mesh.skeleton):
				mesh.skeleton = mesh.get_path_to(theSkeleton)

func _exit_tree() -> void:
	#for mesh in getMeshes():
	#	if(mesh is MeshInstance3D):
	#		mesh.skeleton =  null
	pass

func _ready():
	super._ready()

func grabMaterials():
	pass

func getDollPart() -> DollPart:
	if(!dollPartRef):
		return null
	return dollPartRef.get_ref()

func setDollPart(_dollPart:DollPart):
	if(!_dollPart):
		dollPartRef = null
		return
	dollPartRef = weakref(_dollPart)

func getDoll() -> Doll:
	if(dollPartRef == null):
		return null
	return getDollPart().getDoll()

func getPart() -> GenericPart:
	if(dollPartRef == null):
		return null
	return getDollPart().getPart()
