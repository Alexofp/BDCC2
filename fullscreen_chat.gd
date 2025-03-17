extends Node
@onready var chat_label: RichTextLabel = %ChatLabel
@onready var remove_message_timer: Timer = %RemoveMessageTimer

var messages:Array = []
const MaxMessages = 20
const MessageRemoveTime = 5.0

func addMessage(theText:String):
	messages.append(theText)
	while(messages.size() > MaxMessages):
		messages.pop_front()
	triggerUpdate()
	remove_message_timer.start(MessageRemoveTime)

func addErrorMessage(theText:String):
	addMessage("[color=red]"+theText+"[/color]")

func clear():
	messages.clear()
	triggerUpdate()

var needsUpdate:bool = false
func triggerUpdate():
	if(needsUpdate):
		return
	needsUpdate = true
	updateLabel.call_deferred()

func updateLabel():
	chat_label.text = Util.join(messages, "\n")
	needsUpdate = false


func _on_remove_message_timer_timeout() -> void:
	if(messages.is_empty()):
		remove_message_timer.stop()
		return
	messages.pop_front()
	triggerUpdate()
	if(messages.is_empty()):
		remove_message_timer.stop()
