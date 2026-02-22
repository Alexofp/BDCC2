@tool
extends MeshInstance3D

func _ready() -> void:
	if(!Engine.is_editor_hint()):
		OPTIONS.changedLightShaftsSetting.connect(updateVis)
		updateVis()

func updateVis():
	if(OPTIONS.graphics.lightShafts == GraphicsSettings.LIGHTSHAFTS.DISABLED):
		visible = false
	else:
		visible = true

func setColor(_color:Color):
	set_instance_shader_parameter("base_color", _color)
