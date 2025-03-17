extends Camera3D
class_name PriorityCamera

@export var cameraActive:bool = false
@export var cameraPriority:float = 0.0

func isCameraConsideredActive() -> bool:
	return cameraActive

## CameraSystem will pick the camera that has the biggest priority as the active one each frame
func getCameraPriority() -> float:
	return cameraPriority

func isActive() -> bool:
	return current

func _enter_tree() -> void:
	CameraSystem.addCamera(self)

func _exit_tree() -> void:
	CameraSystem.removeCamera(self)
