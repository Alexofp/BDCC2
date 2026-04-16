extends HFlowContainer

# [ [name, disabled, indx], [name, disabled, indx], ...]
var savedActions:Array[Array] = []
var buttons:Array[Button] = []

signal onButton(buttonIndex:int)

# Make sure you pass a new array each time
func setActions(_actions:Array[Array]):
	if(savedActions.size() == _actions.size() && savedActions == _actions):
		return
	var oldAm:int = savedActions.size()
	var newAm:int = _actions.size()
	var diffAm:int = newAm - oldAm # How many buttons need to be created/removed
	
	if(diffAm > 0):
		for _i:int in diffAm:
			var newButton:Button = Button.new()
			add_child(newButton)
			newButton.pressed.connect(onButtonPressed.bind(newButton, buttons.size()))
			buttons.append(newButton)
	elif(diffAm < 0):
		for _i:int in (-diffAm):
			buttons[buttons.size()-1].queue_free()
			buttons.pop_back()
	
	for _i:int in newAm:
		var theAction:Array = _actions[_i]
		var theButton:Button = buttons[_i]
		theButton.text = theAction[0]
		theButton.disabled = theAction[1]
		theButton.set_meta("extra_indx", theAction[2])
	
	savedActions = _actions

func onButtonPressed(_button:Button, _indx:int):
	#onButton.emit(_indx)
	onButton.emit(_button.get_meta("extra_indx", 0))
