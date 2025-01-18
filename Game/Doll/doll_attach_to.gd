extends Node3D

@export var attachPoint:String = ""
@export var skeletonMeshes:Array[MeshInstance3D] = []
var savedPoint:DollAttachPoint

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
			if(pointNode == null):
				for mesh in skeletonMeshes:
					mesh.skeleton = NodePath("")
					#print("SET SKELETON TO NULL")
			else:
				var pointSkeleton:Skeleton3D = pointNode.getSkeleton()
				for mesh in skeletonMeshes:
					mesh.skeleton = mesh.get_path_to(pointSkeleton) if pointSkeleton != null else NodePath("")
					#print("SET SKELETON TO "+("(NULL) " if pointSkeleton==null else "")+"SKELETON")
		
		if(pointNode == null):
			visible = false
		else:
			visible = true
		
		if(pointNode != null):
			global_transform = pointNode.global_transform
		savedPoint = pointNode
