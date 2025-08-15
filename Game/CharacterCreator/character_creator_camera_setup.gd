extends Node3D
class_name CharacterCreatorCameraSetup

@onready var camera_pivot: Node3D = %CameraPivot
@onready var priority_camera: PriorityCamera = %PriorityCamera

#var pivotAround:bool = false
var characterCreatorRef:WeakRef
var zone:int = CharCreatorZone.ALL

func getCharCreator():
	if(characterCreatorRef == null):
		return null
	return characterCreatorRef.get_ref()

func setCharCreator(_newCharCreator):
	if(!_newCharCreator):
		characterCreatorRef = null
		return
	characterCreatorRef = weakref(_newCharCreator)

func getDoll() -> Doll:
	var theCharCreator = getCharCreator()
	if(theCharCreator == null):
		return null
	return theCharCreator.doll

func setZone(_zone:int):
	if(zone == _zone):
		return
	zone = _zone
	camera_pivot.position = CharCreatorZone.getPivotPos(zone)
	priority_camera.fov = CharCreatorZone.getCameraFOV(zone)
	camera_pivot.rotation.x = 0.0
	
func shouldPivotAround() -> bool:
	return CharCreatorZone.isPivotAround(zone)
#func setPivotAround(_newPivot:bool):
#	pivotAround = _newPivot

func resetPivot():
	pass

func _process(_delta: float) -> void:
	var theDoll := getDoll()
	if(theDoll):
		var boneToFollow:String = CharCreatorZone.getFollowBone(zone)
		if(boneToFollow != ""):
			camera_pivot.global_position = theDoll.getBonePos(boneToFollow, CharCreatorZone.getPivotPos(zone))
	priority_camera.position.z = CharCreatorZone.getCameraDist(zone)
	
	updateHOffset()

func updateHOffset():
	var theOffset:float = 0.0
	
	var currentFOV:float = priority_camera.fov
	if(currentFOV <= 40.0):
		theOffset = remap(currentFOV, 10.0, 40.0, 0.04, 0.12)
	elif(currentFOV <= 100.0):
		theOffset = remap(currentFOV, 40.0, 100.0, 0.12, 0.3)
	else:
		theOffset = 0.3
	priority_camera.h_offset = theOffset * remap(priority_camera.position.z, 0.5, 1.1, 0.3, 1.0)
	
	if(!shouldPivotAround()):
		var cameraPitch:float = 10.0
		if(currentFOV <= 40.0):
			cameraPitch = remap(currentFOV, 20.0, 60.0, 0.0, 10.0)
		priority_camera.rotation_degrees.x = -cameraPitch
	else:
		priority_camera.rotation_degrees.x = 0.0

func handleZoom(mouseZ:float):
	var currentFOV:float = priority_camera.fov
	currentFOV += mouseZ * 5.0
	if(currentFOV > 120.0):
		currentFOV = 120.0
	if(currentFOV < 10.0):
		currentFOV = 10.0
	priority_camera.fov = currentFOV

func handleMouseMove(mouseD:Vector2):
	const sensivity = 0.3
	
	if(shouldPivotAround()):
		rotateCamera(camera_pivot, mouseD.x * sensivity, mouseD.y * sensivity)
	else:
		rotateCamera(camera_pivot, mouseD.x * sensivity, 0.0)
		camera_pivot.position.y += mouseD.y * 0.002
		camera_pivot.position.y = clamp(camera_pivot.position.y, 0.05, 2.0)

func rotateCamera(theCamera:Node3D, roty:float, rotx:float):
	var rot := theCamera.rotation_degrees
	rot.x = clamp(rot.x - rotx, -90.0, 90)
	rot.y -= roty
	theCamera.rotation_degrees = rot
