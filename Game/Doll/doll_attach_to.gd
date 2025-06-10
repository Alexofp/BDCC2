extends Node3D
class_name DollAttachTo

@export var attachPoint:String = ""
@export var skeletonMeshes:Array[MeshInstance3D] = []
var savedPoint:DollAttachPoint

#func _ready() -> void:
#	process_priority = 99999

func getDoll() -> Doll:
	var result:Node = get_parent()
	
	while(result != null):
		if(result is Doll):
			return result
		result = result.get_parent()
	return null

func _process(_delta: float) -> void:
	var doll := getDoll()
	if(doll != null):
		var pointNode := doll.getAttachPoint(attachPoint)
		
		if(pointNode != savedPoint):
			onNewAttachPoint(savedPoint, pointNode)

		if(pointNode == null):
			visible = false
		else:
			visible = true
		
		#if(pointNode != null):
			#global_transform = pointNode.global_transform
			#doPos.call_deferred(pointNode)
		savedPoint = pointNode

func doPos(theNode:Node3D):
	if(theNode && theNode.is_inside_tree() && is_inside_tree()):
		global_transform = theNode.global_transform

func onNewAttachPoint(oldPoint, newPoint):
	if(oldPoint):
		oldPoint.removeAttach(self)
		#oldPoint.attached.erase(self)
	if(newPoint):
		newPoint.addAttach(self)
		#newPoint.attached.append(self)
	
	if(newPoint == null || !is_instance_valid(newPoint)):
		for mesh in skeletonMeshes:
			mesh.skeleton = NodePath("")
			#print("SET SKELETON TO NULL")
	else:
		var pointSkeleton:Skeleton3D = newPoint.getSkeleton()
		for mesh in skeletonMeshes:
			mesh.skeleton = mesh.get_path_to(pointSkeleton) if pointSkeleton != null else NodePath("")
			#print("SET SKELETON TO "+("(NULL) " if pointSkeleton==null else "")+"SKELETON")
	


func _exit_tree() -> void:
	if(savedPoint && is_instance_valid(savedPoint)):
		savedPoint.removeAttach(self)
