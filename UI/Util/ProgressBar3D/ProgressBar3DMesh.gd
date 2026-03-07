@tool
extends MeshInstance3D

@export_range(0.0, 1.0) var progress:float = 0.0: set = setProgress

func setProgress(_p:float):
	if(_p == progress):
		return
	progress = _p
	set_instance_shader_parameter("progress", _p)

var smoothTween:Tween

func setProgressSmooth(_p:float):
	if(smoothTween):
		smoothTween.kill()
	smoothTween = create_tween()
	smoothTween.tween_property(self, "progress", _p, 0.1)
