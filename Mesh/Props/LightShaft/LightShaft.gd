@tool
extends MeshInstance3D

@export var disableIfVolumetricFog:bool = false

func _ready() -> void:
	if(!Engine.is_editor_hint()):
		OPTIONS.changedLightShaftsSetting.connect(updateVis)
		OPTIONS.changedFogSetting.connect(updateVis)
		updateVis()

func updateVis():
	if(OPTIONS.graphics.lightShafts == GraphicsSettings.LIGHTSHAFTS.DISABLED):
		visible = false
	else:
		visible = true
	if(disableIfVolumetricFog && visible):
		visible = (OPTIONS.graphics.fog != GraphicsSettings.FOG.VOLUMETRIC)

func setColor(_color:Color):
	set_instance_shader_parameter("base_color", _color)
