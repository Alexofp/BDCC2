extends Node3D

var value:float = 0.0
#var firstSet:bool = true

@onready var hover_text: Label3D = %HoverText
@onready var outline_sprite: Sprite3D = %OutlineSprite
@onready var fill_sprite: Sprite3D = %FillSprite
@onready var progress_bar_3d_mesh: MeshInstance3D = %ProgressBar3DMesh

const SPRITE_SIZE:float = 256.0

var keyText:String = ""

func _ready() -> void:
	hover_text.text = ""
	progress_bar_3d_mesh.progress = value

func setValue(_val:float):
	_val = clamp(_val, 0.0, 1.0)
	#if(abs(_val - value)<0.01 && !firstSet):
	#	return
	#firstSet = false
	value = _val
	#progress_bar_3d_mesh.setProgressSmooth(value)
	progress_bar_3d_mesh.progress = value
	#fill_sprite.region_rect.size.x = value * SPRITE_SIZE
	#fill_sprite.offset.x = -(-value+1.0) * SPRITE_SIZE * 0.5

func setText(_str:String, _actualText:String = ""):
	if(_actualText.is_empty()):
		_actualText = _str
	if(keyText == _str):
		return
	keyText = _str
	hover_text.text = _actualText
