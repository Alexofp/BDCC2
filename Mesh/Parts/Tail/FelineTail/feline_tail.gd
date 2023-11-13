extends DollPart

@onready var tail = $"RIG-TailRig/Skeleton3D/FelineTail2"
@onready var animPlayer = $AnimationPlayer
@export var tailMat:StandardMaterial3D
@export var tailPatternMat:ShaderMaterial

func _ready():
	super._ready()

func applyOption(_optionID: String, _value):
	if(_optionID == "tailthick"):
		setBlendshape(tail, "ThickTail", _value)
	if(_optionID == "tailspirtal"):
		setBlendshape(tail, "SpiralTail", _value)
	if(_optionID == "tailbat"):
		setBlendshape(tail, "BatTail", _value)
		
func applySkinOption(_optionID: String, _value):
	if(_optionID == "tailpattern"):
		if(tailPatternMat != null):
			tailPatternMat.set_shader_parameter("source_texture_mask", GlobalRegistry.getTextureVariant(TextureType.Pattern, TextureSubType.Generic, _value[0]).getTexture())
			tailPatternMat.set_shader_parameter("source_texture_red", _value[1])
			tailPatternMat.set_shader_parameter("source_texture_green", _value[2])
			tailPatternMat.set_shader_parameter("source_texture_blue", _value[3])
	if(_optionID == "patternscale"):
		if(tailPatternMat != null):
			tailPatternMat.set_shader_parameter("uv1_scale", Vector3(_value+1.0,_value+1.0,_value+1.0))

var curAnim = ""
func playAnim(dollAnim:String, _howFast:float = 1.0):
	if(dollAnim in [DollAnim.Walk, DollAnim.Run, DollAnim.Fall]):
		if(curAnim != "TailIdle"):
			curAnim = "TailIdle"
			animPlayer.play("TailIdle")
	else:
		if(curAnim != "TailWag"):
			curAnim = "TailWag"
			animPlayer.play("TailWag")

func applyBaseSkinData(_data : BaseSkinData):
	if(tailMat != null):
		tailMat.albedo_color = _data.skinColor
	if(tailPatternMat != null):
		tailPatternMat.set_shader_parameter("albedo", _data.skinColor)
