@tool
extends "res://Mapping/MainHallBasic.gd"

@onready var light_shaft: MeshInstance3D = $LightShaft
@onready var light_shaft_2: MeshInstance3D = $LightShaft2
@onready var light_shaft_3: MeshInstance3D = $LightShaft3
@onready var light_shaft_4: MeshInstance3D = $LightShaft4
@onready var light_shaft_5: MeshInstance3D = $LightShaft5

func applyEditorOption(_id, _value):
	super.applyEditorOption(_id, _value)
	if(_id == "color3"):
		if(light_shaft):
			var newCol:Color = _value
			newCol.v = 1.0
			light_shaft.setColor(newCol)
			light_shaft_2.setColor(newCol)
			light_shaft_3.setColor(newCol)
			light_shaft_4.setColor(newCol)
			light_shaft_5.setColor(newCol)
