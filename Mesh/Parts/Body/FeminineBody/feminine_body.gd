extends DollPart

@onready var body = $rig/Skeleton3D/Body
@onready var animTree = $SkeletonAnimTree

func _ready():
	super._ready()
	animTree.active = true

func applyOption(_optionID: String, _value):
	if(_optionID == "thickbutt"):
		setBlendshape(body, "ThickButt", _value)
	if(_optionID == "breastsize"):
		animTree["parameters/BreastsSize/add_amount"] = _value
	if(_optionID == "headsize"):
		animTree["parameters/HeadSize/add_amount"] = _value * 0.1
	if(_optionID == "height"):
		animTree["parameters/HeightTall/add_amount"] = _value
