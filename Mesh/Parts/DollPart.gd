extends Node3D

@export var skeleton:Skeleton3D
@onready var body = $rig/Skeleton3D/Body
var meshes:Array[MeshInstance3D] = []

func deleteSkeleton():
	if(skeleton == null):
		return
	for node in skeleton.get_children():
		skeleton.remove_child(node)
		add_child(node)
	skeleton.queue_free()

func _ready():
	deleteSkeleton()
	meshes = Util.getAllMeshInstancesOfANode(self)

func setSkeleton(newSkeleton:Skeleton3D):
	for mesh in meshes:
		mesh.skeleton = mesh.get_path_to(newSkeleton)
