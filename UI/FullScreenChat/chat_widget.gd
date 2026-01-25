extends VBoxContainer

var chatMessageScene := preload("res://UI/FullScreenChat/chat_widget_message.tscn")

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
	
	scrollbar.changed.connect(handleScrollbarChanged)
	max_scroll_length = scrollbar.max_value
	
	fullUpdate()

func addChat(_text:String):
	#TODO: Fix ability to send bbcode
	var newMessage:RichTextLabel = chatMessageScene.instantiate()
	newMessage.text = _text
	
	messages_list.add_child(newMessage)
	messages.append(newMessage)
	
	while(messages.size() > GameChat.MAX_MESSAGES):
		var theMessage:Control = messages.pop_front()
		theMessage.queue_free()
	

func onGameChatMessage(_text:String):
	addChat(_text)

func fullUpdate():
	Util.delete_children(messages_list)
	messages = []
	
	for message in GameChat.getMessages():
		addChat(message)

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
