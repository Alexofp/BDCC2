extends DollPart

@onready var ball_gag_module: MeshInstance3D = $FelineGagHarness/BallGagModule
@onready var ring_gag_module: MeshInstance3D = $FelineGagHarness/RingGagModule
@onready var bottom_strap: MeshInstance3D = $FelineGagHarness/BottomStrap

func onSpawn(_genericType:int, _bodypartSlot:int, _id:String):
	ball_gag_module.visible = (_id == "BallGag")
	ring_gag_module.visible = (_id == "RingGag")
	bottom_strap.visible = (!ball_gag_module.visible && !ring_gag_module.visible)
	
func gatherPartFlags(_theFlags:Dictionary):
	if(ball_gag_module.visible):
		_theFlags["HeadBallGag"] = true
	if(ring_gag_module.visible):
		_theFlags["HeadRingGag"] = true

func applyOption(_optionID:String, _value:Variant):
	if(ball_gag_module != null):
		if(_optionID == "ballColor"):
			ball_gag_module.set_instance_shader_parameter("trim_color_main", _value)
