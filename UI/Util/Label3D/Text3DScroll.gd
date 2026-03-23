@tool
extends Label3D

@onready var label_sizing: Label3D = %LabelSizing

@export var textAnimated:String = "": set = setTextAnimated
@export_range(0.0, 1.0) var textProgress:float = 0.0: set = setTextProgress
@export var autoProgress:bool = true
@export_range(0.01, 20.0) var autoProgressTime:float = 0.3
@export var minSpeed:float = 2.0

var autoProgressMinSpeed:float = 0.0

func setTextInstant(_t:String):
	textAnimated = _t
	textProgress = 1.0

func setTextAnimated(_t:String):
	textAnimated = _t
	
	label_sizing.text = textAnimated
	#label_main.text = text
	updateMainText()

func setTextProgress(_p:float):
	textProgress = clamp(_p, 0.0, 1.0)
	updateMainText()

func updateMainText():
	var textAm:int = textAnimated.length()
	var showLetters:int = int(round(float(textAm) * textProgress))
	text = textAnimated.substr(0, showLetters)
	autoProgressMinSpeed = (1.0 / float(textAm))*minSpeed if textAm > 0 else 0.0

func _physics_process(_delta: float) -> void:
	if(horizontal_alignment == HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT):
		var theSizeX:float = label_sizing.get_aabb().size.x
		offset.x = -theSizeX*0.5 / pixel_size
	else:
		offset.x = 0.0
	
	if(autoProgress && textProgress < 1.0):
		textProgress += maxf(_delta / autoProgressTime, autoProgressMinSpeed)
