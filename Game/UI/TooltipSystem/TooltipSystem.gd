extends CanvasLayer

var trackedObj:WeakRef

@onready var tooltip_panel: PanelContainer = %TooltipPanel
@onready var name_label: Label = %NameLabel
@onready var desc_label: RichTextLabel = %DescLabel

var timeBeforeShow:float = 0.0
var showBelow:bool = false

func _ready() -> void:
	internal_hide()

func showTooltip(_obj:Node, _name:String, _desc:String, _showBelow:bool = false, _time:float = 0.2):
	if(!_obj):
		return
	var theOldObj:Node = null if !trackedObj else trackedObj.get_ref()
	if(theOldObj != _obj):
		timeBeforeShow = _time
	visible = true
	#TODO: Delay is borked, figure out why
	#visible = (timeBeforeShow <= 0.0) # BREAKS STUFF. WHY?
	tooltip_panel.size.y = 16.0
	trackedObj = weakref(_obj)
	name_label.text = _name
	desc_label.text = _desc
	set_process(true)
	showBelow = _showBelow
	

func hideTooltip(_obj:Node):
	if(trackedObj && trackedObj.get_ref() == _obj):
		internal_hide()

func internal_hide():
	trackedObj = null
	set_process(false)
	visible = false

func _process(_delta: float) -> void:
	if(!trackedObj || !trackedObj.get_ref()):
		internal_hide()
		return
	if(timeBeforeShow > 0.0):
		timeBeforeShow -= _delta
		if(timeBeforeShow <= 0.0):
			visible = true
	if(showBelow):
		tooltip_panel.global_position = tooltip_panel.get_global_mouse_position() - Vector2(tooltip_panel.size.x/2.0, -20.0) + tooltip_panel.pivot_offset
	else:
		tooltip_panel.global_position = tooltip_panel.get_global_mouse_position() - Vector2(tooltip_panel.size.x/2.0, tooltip_panel.size.y+10.0) - tooltip_panel.pivot_offset
	tooltip_panel.global_position.x = max(10, tooltip_panel.global_position.x)
	tooltip_panel.global_position.x = min(tooltip_panel.get_viewport_rect().size.x - 10 - tooltip_panel.size.x, tooltip_panel.global_position.x)
	tooltip_panel.global_position.y = max(10, tooltip_panel.global_position.y)
	tooltip_panel.global_position.y = min(tooltip_panel.get_viewport_rect().size.y - 10 - tooltip_panel.size.y, tooltip_panel.global_position.y)
