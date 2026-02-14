@tool
extends MeshInstance3D

@export var texture:Texture: set = _setTexture
@export var textureBack:Texture: set = _setBackTexture
@export_range(0.0, 1.0) var progress:float = 0.0: set = _setProgress
@export_range(0.0, 1.0) var smoothness:float = 0.2: set = _setSmooth
@export var colorMain:Color = Color.WHITE: set = _setMainColor
@export var colorBack:Color = Color.WHITE: set = _setBackColor
@export_range(0.0, 1.0) var size:float = 1.0: set = _setQuadSize
@export var textureProgress:Texture = preload("res://UI/Util/RadialProgressBar3D/RadialProgress.png"): set = _setProgressTexture
@export_range(0.0, 1.0) var finalAlpha:float = 1.0: set = _setFinalAlpha

func _setTexture(_val:Texture):
	texture = _val
	get_surface_override_material(0).set_shader_parameter("texture_albedo", texture)
	
func _setBackTexture(_val:Texture):
	textureBack = _val
	get_surface_override_material(0).set_shader_parameter("texture_back", textureBack)

func _setProgress(_val:float):
	progress = _val
	get_surface_override_material(0).set_shader_parameter("amount", 1.0-progress)
	
func _setSmooth(_val:float):
	smoothness = _val
	get_surface_override_material(0).set_shader_parameter("smoothness", smoothness)
	
func _setMainColor(_val:Color):
	colorMain = _val
	get_surface_override_material(0).set_shader_parameter("albedo", colorMain)
	
func _setBackColor(_val:Color):
	colorBack = _val
	get_surface_override_material(0).set_shader_parameter("color_back", colorBack)

func _setQuadSize(_val:float):
	size = _val
	get_surface_override_material(0).set_shader_parameter("mesh_size", size)

func _setFinalAlpha(_val:float):
	finalAlpha = _val
	get_surface_override_material(0).set_shader_parameter("alpha_final", finalAlpha)

func _setProgressTexture(_texture:Texture):
	textureProgress = _texture
	get_surface_override_material(0).set_shader_parameter("progressImage", textureProgress)

func pushValueTowards(_val:float) -> bool:
	_val = clamp(_val, 0.0, 1.0)
	if(_val == progress):
		return false
	if(abs(_val - progress) < 0.01):
		progress = _val
		return true
	progress = lerp(progress, _val, 0.2)
	return true

var shouldBarsBeVisible:bool = false
var fadeTween:Tween
func fadeIn(_force:bool = false):
	if(!shouldBarsBeVisible):
		return
	shouldBarsBeVisible = false

	if(fadeTween):
		fadeTween.kill()
	if(_force):
		finalAlpha = 1.0
		return
	fadeTween = create_tween()
	fadeTween.tween_property(self, "finalAlpha", 1.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func fadeOut(_force:bool = false):
	if(shouldBarsBeVisible):
		return
	shouldBarsBeVisible = true
	
	if(fadeTween):
		fadeTween.kill()
	if(_force):
		finalAlpha = 0.0
		return
	fadeTween = create_tween()
	fadeTween.tween_property(self, "finalAlpha", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
