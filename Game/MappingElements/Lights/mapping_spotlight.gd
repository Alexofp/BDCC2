extends SpotLight3D

@export var ignoreLightsDistanceSetting:bool = false

func _ready() -> void:
	#if(distance_fade_begin > 30.0):
	#	ignoreLightsDistanceSetting = true
	OPTIONS.changedLightsQuality.connect(updateLight)
	updateLight()

func updateLight():
	if(ignoreLightsDistanceSetting):
		return
	var theSetting:int = OPTIONS.graphics.lightsDistance
	
	if(theSetting == GraphicsSettings.LIGHTSDISTANCE.LOW):
		distance_fade_begin = 10.0
		distance_fade_length = 5.0
	elif(theSetting == GraphicsSettings.LIGHTSDISTANCE.MEDIUM):
		distance_fade_begin = 20.0
		distance_fade_length = 7.0
	elif(theSetting == GraphicsSettings.LIGHTSDISTANCE.FAR):
		distance_fade_begin = 30.0
		distance_fade_length = 10.0
	else:
		distance_fade_begin = 300.0
		distance_fade_length = 10.0
