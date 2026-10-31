extends VBoxContainer

var chatMessageScene := preload("res://UI/FullScreenChat/chat_widget_message.tscn")
const CHAT_WIDGET_MESSAGE_SIMPLE = preload("res://UI/FullScreenChat/ChatWidgetMessageSimple.tscn")

@onready var messages_list: VBoxContainer = %MessagesList
@onready var chat_line_edit: LineEdit = %ChatLineEdit
@onready var scroll_container: ScrollContainer = %ScrollContainer

var max_scroll_length:float = 0.0
@onready var scrollbar:VScrollBar = scroll_container.get_v_scroll_bar()

var messages:Array[Control] = []

signal onMessageSent(text:String)
signal onTyping(text:String)

func _ready() -> void:
	GameChat.onMessage.connect(onGameChatMessage)
	GameChat.onClear.connect(onGameChatClear)
	
	scrollbar.changed.connect(handleScrollbarChanged)
	max_scroll_length = scrollbar.max_value
	
	fullUpdate()

func addChat(_text:String, _color:Color = Color.WHITE, _bbcode:bool = false):
	#TODO: Fix ability to send bbcode
	#var newMessage:RichTextLabel = chatMessageScene.instantiate()
	var theNewMessage:Control
	if(!_bbcode):
		var newMessage:Label = CHAT_WIDGET_MESSAGE_SIMPLE.instantiate()
		newMessage.text = _text
		newMessage.add_theme_color_override("font_color", _color)
		theNewMessage = newMessage
	else:
		var newMessage:RichTextLabel = chatMessageScene.instantiate()
		newMessage.push_color(_color)
		newMessage.append_text(_text)
		#newMessage.add_text(_text)
		newMessage.pop()
		newMessage.text = _text
		theNewMessage = newMessage
	
	if(!theNewMessage):
		return
	messages_list.add_child(theNewMessage)
	messages.append(theNewMessage)
	
	while(messages.size() > GameChat.MAX_MESSAGES):
		var theMessage:Control = messages.pop_front()
		theMessage.queue_free()

func onGameChatClear():
	fullUpdate()

func onGameChatMessage(_message:ChatMessage):
	addChat(_message.text, _message.color)

func fullUpdate():
	Util.delete_children(messages_list)
	messages = []
	
	for message:ChatMessage in GameChat.getMessages():
		addChat(message.text, message.color)

func handleScrollbarChanged():
	if max_scroll_length != scrollbar.max_value: 
		max_scroll_length = scrollbar.max_value 
	scroll_container.scroll_vertical = int(max_scroll_length)

func _on_chat_line_edit_text_submitted(_new_text: String) -> void:
	#TODO: A send chat function that actually makes the character try to say stuff
	#GameChat.addChat(_new_text)
	GM.sendChat(_new_text)
	chat_line_edit.text = ""
	
	onMessageSent.emit(_new_text)
	
	chat_line_edit.release_focus()

func grabLineEditFocus():
	chat_line_edit.grab_focus()

func hasLineEditFocus() -> bool:
	return chat_line_edit.is_editing() || chat_line_edit.has_focus()

func releaseLineEditFocus():
	chat_line_edit.release_focus()
	chat_line_edit.unedit()

func _on_chat_line_edit_text_changed(_new_text: String) -> void:
	GI.notifyTyping(_new_text)
	onTyping.emit(_new_text)
