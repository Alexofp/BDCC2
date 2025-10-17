extends PanelContainer
class_name ResistMinigame

@onready var main_marker: Panel = %MainMarker
@onready var other_marker: Panel = %OtherMarker
@onready var yellow_panel: Panel = %YellowPanel
@onready var red_panel: Panel = %RedPanel
@onready var main_panel: Panel = %MainPanel
@onready var time_bar: ProgressBar = %TimeBar
@onready var intro_control: Control = %IntroControl
@onready var intro_timer: Timer = %IntroTimer
@onready var main_control: Control = %MainControl
@onready var result_label: Label = %ResultLabel

const OTHER_MARKER = preload("res://Game/UI/ResistMinigame/other_marker.tscn")

signal onClick(pos:float)

var markers:Array[Control] = []

#var markerPos:float = 0.0
var markerTime:float = 0.0
var markerSpeed:float = 1.0

var timeLeft:float = 0.0
var timeFull:float = 0.0

var isFrozen:bool = false

var runningMarkers:Array = []
var runningMarkerControls:Array[Control] = []

func _ready() -> void:
	#runTimerBar(10.0)
	#setRedZone(RNG.randfRange(0.0, 1.0), 0.1)
	#showIntro()
	pass

func _process(_delta: float) -> void:
	if(main_control.visible):
		processGame(_delta)
		processRunningMarkers(_delta)

static func calcPosFromTime(_time:float) -> float:
	return (sin(_time)+1.0)*0.5

func processGame(_delta:float):
	if(!isFrozen):
		markerTime += _delta * markerSpeed
	#print(markerTime)
	
	var thePos := calcPosFromTime(markerTime)
	
	setMarkerPos(thePos)
	
	#if(Input.is_action_just_pressed("game_interact")):
	#	addSmallMarker(thePos, "you")
	
	time_bar.visible = false
	if(timeFull > 0.0):
		#if(!isFrozen):
		timeLeft -= _delta
		if(timeLeft < 0.0):
			timeLeft = 0.0
			timeFull = 0.0
		else:
			time_bar.visible = true
			time_bar.value = timeLeft / timeFull

func setMainMarkerPos(_pos:float):
	#if(_pos < 0.5):
	#	_pos = -_pos
	_pos = clamp(_pos, -1.0, 1.0)
	markerTime = asin(_pos*2.0 - 1.0)
	#print(_pos, " ", markerTime)
	#TODO: some way to flip the direction?

func setMarkerPos(_pos:float):
	main_marker.anchor_left = _pos
	main_marker.anchor_right = _pos

func getMarkerPos() -> float:
	return main_marker.anchor_left

func clearSmallMarkers():
	for theMarker in markers:
		theMarker.queue_free()
	markers.clear()

func addSmallMarker(_pos:float, _text:String = ""):
	var newMarker:Control = OTHER_MARKER.instantiate()
	main_panel.add_child(newMarker)
	newMarker.anchor_left = _pos
	newMarker.anchor_right = _pos
	newMarker.setLabel(_text)
	markers.append(newMarker)

func runTimerBar(_timer:float):
	timeLeft = _timer
	timeFull = _timer

func setTimerBar(_timer:float, _timerLeft:float):
	timeLeft = _timerLeft
	timeFull = _timer

func _on_main_control_gui_input(_event: InputEvent) -> void:
	if(isFrozen):
		return
	if(_event is InputEventMouseButton):
		if(_event.is_pressed() && _event.button_index == MouseButton.MOUSE_BUTTON_LEFT):
			var theMarkerPos := getMarkerPos()
			
			addSmallMarker(theMarkerPos, "you")
			
			#print(theMarkerPos)
			onClick.emit(theMarkerPos)
			setIsFrozen(true)
			
			#await get_tree().create_timer(1.0).timeout
			#setIsFrozen(false)
			#runTimerBar(10.0)
			#setRedZone(RNG.randfRange(0.0, 1.0), 0.1)
			#setMainMarkerPos(RNG.randfRange(0.0, 1.0))

func setIsFrozen(_isF:bool):
	isFrozen = _isF
	#if(isFrozen):
	#	main_marker.visible = false
	#else:
	#	main_marker.visible = true

func showIntro():
	intro_control.visible = true
	main_control.visible = false
	intro_timer.start()

func setIntro(_introVisible:bool):
	if(!_introVisible):
		intro_control.visible = false
		main_control.visible = true
		intro_timer.stop()
		return
	intro_control.visible = true
	main_control.visible = false
	#intro_timer.start(_intro)
	intro_timer.stop()

func setState(_state:int):
	intro_timer.stop()
	if(_state == ResistMinigameNode.STATE_INTRO):
		intro_control.visible = true
		main_control.visible = false
		return
	intro_control.visible = false
	main_control.visible = true

func _on_intro_timer_timeout() -> void:
	intro_control.visible = false
	main_control.visible = true

func setRedZone(_pos:float, _orangeSize:float):
	red_panel.anchor_left = _pos
	red_panel.anchor_right = _pos
	
	yellow_panel.anchor_left = clamp(_pos - _orangeSize, 0.0, 1.0)
	yellow_panel.anchor_right = clamp(_pos + _orangeSize, 0.0, 1.0)

func setResultLabel(_str:String):
	result_label.text = _str

func setTimeRaw(_time:float):
	markerTime = _time

func setSpeedRaw(_speed:float):
	markerSpeed = _speed

#[[charID, time, speed], [...])
func setRunningMarkers(_marks:Array):
	for theMarker in runningMarkerControls:
		theMarker.queue_free()
	runningMarkerControls.clear()
	
	runningMarkers = _marks
	for theEntry in _marks:
		var newMarker:Control = OTHER_MARKER.instantiate()
		main_panel.add_child(newMarker)
		newMarker.anchor_left = calcPosFromTime(theEntry[1])
		newMarker.anchor_right = newMarker.anchor_left
		newMarker.setLabel("")
		runningMarkerControls.append(newMarker)

func processRunningMarkers(_dt:float):
	var _i:int = 0
	for theEntry in runningMarkers:
		theEntry[1] += _dt * theEntry[2]
		var thePos := calcPosFromTime(theEntry[1])
		runningMarkerControls[_i].anchor_left = thePos
		runningMarkerControls[_i].anchor_right = thePos
		_i += 1
		
