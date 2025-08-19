extends Node

@onready var screen: Control = %Screen
@onready var load_label: Label = %LoadLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var canvas_layer: CanvasLayer = %CanvasLayer

func _ready() -> void:
	finishLoad()

func startLoad():
	screen.visible = true
	canvas_layer.visible = true
	animation_player.play("Spin")
	setText("Loading..")

func setText(_text:String):
	load_label.text = _text

func finishLoad():
	screen.visible = false
	canvas_layer.visible = false
	animation_player.stop()
