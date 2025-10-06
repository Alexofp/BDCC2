extends Button
class_name SmartGridButton

var buttonIndex:int = -1
var buttonEntry:SmartGridButtonEntry

signal onPressedActually(entry:SmartGridButtonEntry)

func _on_pressed() -> void:
	onPressedActually.emit(buttonEntry)

# Wrapper methods in case I change how the button interally works
func setText(_text:String):
	text = _text

func setIsDisabled(_dis:bool):
	disabled = _dis

func setEmptyEntry():
	setIsDisabled(true)
	setText(" ")
	buttonEntry = null

func setEntry(_entry:SmartGridButtonEntry):
	if(!_entry):
		setEmptyEntry()
		return
	setIsDisabled(_entry.buttonDisabled)
	setText(_entry.buttonName)
	buttonEntry = _entry
