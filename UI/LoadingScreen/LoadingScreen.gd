extends Node

@onready var screen: Control = %Screen
@onready var load_label: Label = %LoadLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var canvas_layer: CanvasLayer = %CanvasLayer

var messageWindow:AcceptDialog
var loadingWindowScene := preload("res://UI/LoadingScreen/loading_screen_message_window.tscn")

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

func showError(_text:String):
	if(!messageWindow):
		messageWindow = loadingWindowScene.instantiate()
		get_tree().root.add_child(messageWindow)
		messageWindow.addText(_text)
		messageWindow.popup_centered()
		messageWindow.tree_exiting.connect(func(): messageWindow = null)
	else:
		messageWindow.addText(_text)
