extends Node3D
class_name DollAttachPoint

@export var pointName:String = ""
@export var skeleton:Skeleton3D

var attached:Array = []
var nodeToRemote:Dictionary = {}

func getSkeleton() -> Skeleton3D:
	return skeleton

func getDoll() -> Doll:
	var result:Node = get_parent()
	
	while(result != null):
		if(result is Doll):
			return result
		result = result.get_parent()
	return null

func _enter_tree() -> void:
	var doll := getDoll()
	
	if(doll == null):
		Log.error("Attach point couldn't find a doll during creation")
		return
	doll.setupAttachPoint(self)

func _exit_tree() -> void:
	var doll := getDoll()
	
	if(doll == null):
		Log.error("Attach point couldn't find a doll during deletion")
		return
	doll.removeAttachPoint(self)
	
func _process(_delta: float) -> void:
	doPosChilds.call_deferred()
	pass
#func _physics_process(_delta: float) -> void:
	#doPosChilds()
	#pass

func doPosChilds():
	if(!is_inside_tree() || is_queued_for_deletion()):
		return
	for childPoint in attached:
		if(!childPoint || !childPoint.is_inside_tree()):
			continue
		childPoint.global_transform = global_transform
		#childPoint.reset_physics_interpolation()
	#reset_physics_interpolation()

func addAttach(_theNode:Node3D):
	attached.append(_theNode)
	#if(_theNode.get_parent()):
	#	_theNode.get_parent().remove_child(_theNode)
	#add_child(_theNode)
	_theNode.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	
	#var newRemote:RemoteTransform3D = RemoteTransform3D.new()
	#add_child(newRemote)
	#newRemote.process_priority = 999
	#newRemote.process_physics_priority = 999
	#newRemote.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	#newRemote.remote_path = newRemote.get_path_to(_theNode)
	#nodeToRemote[_theNode] = newRemote

func removeAttach(_theNode:Node3D):
	attached.erase(_theNode)
	if(nodeToRemote.has(_theNode)):
		nodeToRemote[_theNode].queue_free()
		#nodeToRemote.erase(_theNode)
