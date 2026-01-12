extends Node3D
class_name HoverTextAdvanced

@onready var progress_bar_3d_simple: Node3D = %ProgressBar3DSimple
@onready var progress_bar_3d_simple_2: Node3D = %ProgressBar3DSimple2
@onready var progress_bar_3d_simple_3: Node3D = %ProgressBar3DSimple3
@onready var hover_text: Label3D = %HoverText

@onready var progressBars:Array[Node3D] = [
	progress_bar_3d_simple,
	progress_bar_3d_simple_2,
	progress_bar_3d_simple_3,
]
var visibleProgressBars:int = 0

const PROGRESS_BAR_SPACING = 0.15

func _ready() -> void:
	for _i in progressBars.size():
		var theProgressBar := progressBars[_i]
		theProgressBar.position = Vector3(0.0, PROGRESS_BAR_SPACING*_i, 0.0)
		theProgressBar.visible = false
	updateHoverTextHeight()

func _process(_delta: float) -> void:
	global_rotation = Vector3(0.0, 0.0, 0.0)

func setHoverText(_text:String):
	if(hover_text.text == _text):
		return
	hover_text.text = _text

func setProgressInfos(_texts:Array[String], _values:Array[float]):
	var tAms:int = _texts.size()
	var vAms:int = _values.size()
	if(tAms > vAms):
		tAms = vAms
	var progAm:int = progressBars.size()
	
	if(tAms > 0):
		set_process(true)
	else:
		set_process(false)
	
	for _i in progAm:
		var theProgressBar := progressBars[_i]
		
		if(_i < tAms):
			theProgressBar.visible = true
			theProgressBar.setValue(_values[_i])
			var theText:String = _texts[_i]
			if(theProgressBar.keyText != theText):
				theProgressBar.setText(theText, GM.textParser.parseStringDefault(theText).text)
		else:
			theProgressBar.visible = false
	
	for _i in progressBars.size():
		var theProgressBar := progressBars[_i]
		theProgressBar.position = Vector3(0.0, PROGRESS_BAR_SPACING*_i, 0.0)
	#set_process(true)
	
	visibleProgressBars = tAms
	updateHoverTextHeight()
	
func updateHoverTextHeight():
	if(visibleProgressBars <= 0):
		hover_text.position.y = 0.0
	else:
		hover_text.position.y = PROGRESS_BAR_SPACING*visibleProgressBars + 0.0
	
