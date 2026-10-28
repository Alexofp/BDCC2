extends Node

const MAX_MESSAGES = 20

var messages:Array[String] = []

signal onMessage(text)
signal onClear

func addChat(_text:String):
	messages.append(_text)
	onMessage.emit(_text)
	
	while(messages.size() > MAX_MESSAGES):
		messages.pop_front()

func getMessages() -> Array[String]:
	return messages

func clear(_sendSignal:bool = true):
	messages.clear()
	if(_sendSignal):
		onClear.emit()
