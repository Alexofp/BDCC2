@tool
extends PropBasic

@onready var spot_light_3d: SpotLight3D = $WallLightBig/SpotLight3D
@onready var light_shaft: MeshInstance3D = %LightShaft

@export var roughness:float = 0.5:
	set(value):
		roughness = value
		notifySetEditorValue("roughness", value)
@export var colorbase:Color = Color("868686"):
	set(value):
		colorbase = value
		notifySetEditorValue("colorbase", value)
@export var color1:Color = Color("303030"):
	set(value):
		color1 = value
		notifySetEditorValue("color1", value)
@export var color3:Color = Color("00E0FF"):
	set(value):
		color3 = value
		notifySetEditorValue("color3", value)
@export_range(0.0, 2.0, 0.05) var lightSpecular:float = 0.2:
	set(value):
		lightSpecular = value
		notifySetEditorValue("lightSpecular", value)
@export_range(0.0, 500.0, 1.0) var lightRange:float = 15.0:
	set(value):
		lightRange = value
		notifySetEditorValue("lightRange", value)
@export_range(0.0, 100.0, 1.0) var lightEnergy:float = 8.0:
	set(value):
		lightEnergy = value
		notifySetEditorValue("lightEnergy", value)

func getEditorOptionsEasy() -> Dictionary:
	var theSettings:Dictionary =  {
		"roughness": {type="roughness"},
		"colorbase": {type="color"},
		"color1": {type="color"},
		#"color2": {type="color"},
		"color3": {type="colorLight"},
	}
	return theSettings

func applyEditorOption(_id, _value):
	super.applyEditorOption(_id, _value)
	if(_id == "color3"):
		if(spot_light_3d):
			spot_light_3d.light_color = _value
		if(light_shaft):
			light_shaft.setColor(_value)
	if(_id == "lightSpecular"):
		if(spot_light_3d):
			spot_light_3d.light_specular = _value
	if(_id == "lightRange"):
		if(spot_light_3d):
			spot_light_3d.spot_range = _value
	if(_id == "lightEnergy"):
		if(spot_light_3d):
			spot_light_3d.light_energy = _value

func getEditorOptionsID() -> String:
	return EDITOR_OPTIONS_ID_WALLLIGHT
