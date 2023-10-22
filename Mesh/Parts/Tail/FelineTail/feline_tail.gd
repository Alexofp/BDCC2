extends DollPart

@onready var tail = $"RIG-TailRig/Skeleton3D/FelineTail2"
@onready var animPlayer = $AnimationPlayer

func _ready():
	super._ready()

func applyOption(_optionID: String, _value):
	if(_optionID == "tailthick"):
		setBlendshape(tail, "ThickTail", _value)
	if(_optionID == "tailspirtal"):
		setBlendshape(tail, "SpiralTail", _value)
	if(_optionID == "tailbat"):
		setBlendshape(tail, "BatTail", _value)

var curAnim = ""
func playAnim(dollAnim:String, howFast:float = 1.0):
	if(dollAnim in [DollAnim.Walk, DollAnim.Run, DollAnim.Fall]):
		if(curAnim != "TailIdle"):
			curAnim = "TailIdle"
			animPlayer.play("TailIdle")
	else:
		if(curAnim != "TailWag"):
			curAnim = "TailWag"
			animPlayer.play("TailWag")
