extends DollPart

@onready var digi_legs: MeshInstance3D = %DigiLegs
@onready var planti_legs: MeshInstance3D = %PlantiLegs

func applyOption(_optionID:String, _value:Variant):
	if(_optionID == "thickness"):
		var thinValue:float = 0.0
		var thickValue:float = 0.0
		if(_value > 0.5):
			thickValue = (_value - 0.5)*2.0
		if(_value < 0.5):
			thinValue = (0.5 - _value)*2.0
		setBlendshape("ThinVery", thinValue)
		setBlendshape("Thick", thickValue)
	if(_optionID == "legType"):
		digi_legs.visible = (_value == "digi")
		planti_legs.visible = (_value == "planti")
