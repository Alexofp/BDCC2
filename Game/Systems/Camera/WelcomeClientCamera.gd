extends PriorityCamera
class_name WelcomeClientCamera

func isCameraConsideredActive() -> bool:
	return cameraActive && GM.main && GM.main.isWelcomeClientUIShowing()
