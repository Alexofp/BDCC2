extends PriorityCamera

@export var doll:DollController

func isCameraConsideredActive() -> bool:
	return cameraActive && doll && doll.isControlledByUs()
