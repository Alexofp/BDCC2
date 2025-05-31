extends Node

var cameras:Array[PriorityCamera] = []
var currentCam:PriorityCamera = null

signal currentCameraChanged(oldCamera, newCamera)

func addCamera(newCam:PriorityCamera):
	if(cameras.has(newCam) || !newCam):
		return
	cameras.append(newCam)
	
	if(newCam.isCameraConsideredActive()):
		if(!currentCam || (newCam.getCameraPriority() > currentCam.getCameraPriority())):
			setCurrentCam(newCam)

func removeCamera(aCam:PriorityCamera):
	if(cameras.has(aCam)):
		cameras.erase(aCam)
		
		if(aCam == currentCam):
			setCurrentCam(getActiveCameraWithHighestPriority())

func _process(_delta: float) -> void:
	var newCam:PriorityCamera = getActiveCameraWithHighestPriority()
	if(newCam != currentCam):
		setCurrentCam(newCam)
	
	if(UIHandler.shouldMouseBeCaptured()):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func setCurrentCam(theCam:PriorityCamera):
	var oldCam := currentCam
	if(currentCam):
		currentCam.current = false
	currentCam = theCam
	if(currentCam):
		currentCam.make_current()
	
	if(oldCam != currentCam):
		currentCameraChanged.emit(oldCam, currentCam)

func getActiveCameraWithHighestPriority() -> PriorityCamera:
	if(cameras.is_empty()):
		return null
	var maxcam:PriorityCamera = null
	var maxcamprio:float = -INF
	
	for camera in cameras:
		if(!camera.isCameraConsideredActive()):
			continue
		var newprio:float = camera.getCameraPriority()
		
		if(newprio > maxcamprio):
			maxcamprio = newprio
			maxcam = camera
	
	return maxcam
