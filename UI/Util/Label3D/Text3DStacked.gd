@tool
extends Node3D

@onready var small_hover: Label3D = %SmallHover
@export var timeShow:float = 5.0
var texts:Array #[[text, timer], ...]
@onready var hover_text: Label3D = %HoverText
@export var maxTexts:int = 3
@export var textSpeed:float = 1.0

@export var hoverText:String = ""
var currentTextProgress:float = 0.0

func getHoverText() -> String:
	return hoverText

func setHoverText(_text:String):
	if(hoverText == _text):
		return
	hoverText = _text

func addText(_text:String):
	texts.append([_text, timeShow])
	currentTextProgress = 0.0
	
	while(texts.size() > maxTexts):
		texts.pop_front()

func clearTexts():
	texts.clear()

func getFinalText() -> String:
	var theResult:String = ""#hoverText
	
	var _i:int = 0
	var textAm:int = texts.size()
	for theTextEntry in texts:
		var theCurText:String = theTextEntry[0]
		if(!theResult.is_empty()):
			theResult += "\n"
		
		if(_i == (textAm-1)):
			var amTextLen:int = theCurText.length()
			var howManyLetters:int = int(round(float(amTextLen)*currentTextProgress))
			
			theResult += theCurText.substr(0, howManyLetters)
		else:
			theResult += theCurText
		
		_i += 1
	
	if(!hoverText.is_empty()):
		if(!theResult.is_empty()):
			theResult += "\n"
		theResult += hoverText
	
	return theResult

func getVisText(_text:String, _progres:float) -> String:
	var amTextLen:int = _text.length()
	var howManyLetters:int = int(round(float(amTextLen)*clamp(_progres, 0.0, 1.0)))
	return _text.substr(0, howManyLetters)
	
func canInterupt() -> bool:
	if(texts.is_empty()):
		return false
	if(currentTextProgress < 1.0):
		return true
	
	return false

func doInterupt(_text:String = "-ugh.."):
	texts.back()[1] = 3.0
	var theCurrentText:String = getVisText(texts.back()[0], currentTextProgress)
	texts.back()[0] = theCurrentText + _text
	currentTextProgress = 1.0

var toRemove:Array[int]
func _physics_process(_delta: float) -> void:
	toRemove.clear()
	var _i:int = 0
	for theEntry in texts:
		theEntry[1] -= _delta
		if(theEntry[1] <= 0.0):
			toRemove.append(_i)
		
		_i += 1
	
	var toRemAm:int = toRemove.size()
	for _ii in toRemAm:
		var _indx:int = toRemAm - _ii - 1
		
		texts.remove_at(_indx)
	
	if(!texts.is_empty()):
		var speedAdd:float = _delta * textSpeed
		var theCurText:String = texts.back()[0]
		var minSpeed:float = 1.0/float(theCurText.length()) if !theCurText.is_empty() else 0.0
		speedAdd = maxf(speedAdd, minSpeed)
		
		currentTextProgress = clamp(currentTextProgress + speedAdd, 0.0, 1.0)
	hover_text.text = getFinalText()
	
	if(small_hover.text.is_empty()):
		hover_text.offset.y = 0.0
	else:
		hover_text.offset.y = 51.78
	
const HOVER_TEXT_SMALL = preload("res://Game/Doll/Util/HoverTextSmall.tscn")

var smallTexts:Array[Node]
func addSmallText(_text:String, _color:Color = Color.WHITE):
	var theText:Label3D = HOVER_TEXT_SMALL.instantiate()
	add_child(theText)
	theText.offset.x += 0.4 / theText.pixel_size
	theText.position.y = -0.1*smallTexts.size()
	
	theText.text = _text
	theText.modulate = _color
	smallTexts.append(theText)
	theText.tree_exiting.connect(func(): smallTexts.erase(theText))

func setSmallHoverText(_text:String):
	if(small_hover.text == _text):
		return
	small_hover.text = _text

func addTextText() -> void:
	addText("Hello world Hello world Hello world Hello world Hello world Hello world")

func addSmallTextText() -> void:
	addSmallText("Affection+", Color.GREEN)

func doTestInterrupt():
	if(canInterupt()):
		doInterupt()

@export_tool_button("Add test text", "Callable") var addTextText_action = addTextText
@export_tool_button("Do interrupt", "Callable") var doTestInterrupt_action = doTestInterrupt
@export_tool_button("Add small text", "Callable") var addSmallTextText_action = addSmallTextText
