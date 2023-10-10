extends Node3D
class_name DollPart

@export var skeleton:Skeleton3D
#@onready var body = $rig/Skeleton3D/Body
@export var bindToMainSkeleton = false
var meshes:Array[MeshInstance3D] = []
@export var attachmentPoints:Dictionary = {}

func deleteSkeleton():
	if(skeleton == null):
		return
	for node in skeleton.get_children():
		skeleton.remove_child(node)
		add_child(node)
	skeleton.queue_free()

func _ready():
	if(bindToMainSkeleton):
		deleteSkeleton()
	meshes = Util.getAllMeshInstancesOfANode(self)

func setSkeleton(newSkeleton:Skeleton3D):
	for mesh in meshes:
		mesh.skeleton = mesh.get_path_to(newSkeleton)

func getBodypartSlotObject(bodypartSlot: String):
	if(attachmentPoints.has(bodypartSlot)):
		return get_node(attachmentPoints[bodypartSlot])
	return null
