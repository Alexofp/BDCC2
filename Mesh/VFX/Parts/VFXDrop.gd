@tool
extends Node3D

var vfx_drop: MeshInstance3D
@export var material:ShaderMaterial = null: set = setMaterial
@export_range(0.0, 1.0) var fill:float = 1.0: set = setFill

func _init() -> void:
	vfx_drop = get_child(0)

func setMaterial(_mat:ShaderMaterial):
	material = _mat
	vfx_drop.set_surface_override_material(0, _mat)
	if(material):
		material.set_shader_parameter("Fill", fill)

func setFill(_f:float):
	fill = _f
	if(material):
		material.set_shader_parameter("Fill", fill)

var fadeTween:Tween
func fadeInOut(_timeIn:float, _timeOut:float, _deleteWhenEnds:bool = true):
	if(fadeTween):
		fadeTween.kill()
	
	fill = 0.0
	fadeTween = create_tween()
	fadeTween.tween_property(self, "fill", 1.0, _timeIn).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	fadeTween.tween_property(self, "fill", 0.0, _timeOut).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	if(_deleteWhenEnds):
		fadeTween.tween_callback(queue_free)
	
