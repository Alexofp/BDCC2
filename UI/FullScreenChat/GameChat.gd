extends Node

const MAX_MESSAGES = 20

var messages:Array[ChatMessage] = []

signal onMessage(_message:ChatMessage)
signal onClear

func addChat(_text:String, _color:Color = Color.WHITE):
	var _newMessage:ChatMessage = ChatMessage.new()
	_newMessage.text = _text
	_newMessage.color = _color
	messages.append(_newMessage)
	onMessage.emit(_newMessage)
	
	while(messages.size() > MAX_MESSAGES):
		messages.pop_front()

func getMessages() -> Array[ChatMessage]:
	return messages

func clear(_sendSignal:bool = true):
	messages.clear()
	if(_sendSignal):
		onClear.emit()
