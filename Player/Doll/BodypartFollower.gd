extends Node3D

@export var doll:Doll
@export var bodypartPath = [BodypartSlot.Head]
@export var bodypartSlot = "Hat"
var objectRefToFollow:WeakRef

func _ready():
	setToFollow(doll, bodypartPath, bodypartSlot)

func setToFollow(newDoll:Doll, newPath:Array, newSlot:String):
	bodypartPath = newPath
	bodypartSlot = newSlot
	
	var oldChar = null
	if(doll != null && is_instance_valid(doll)):
		if(doll.selectedCharacterChanged.is_connected(onCharacterChanged)):
			doll.selectedCharacterChanged.disconnect(onCharacterChanged)
		oldChar = doll.getCharacter()
	doll = newDoll
	if(doll != null && is_instance_valid(doll)):
		doll.selectedCharacterChanged.connect(onCharacterChanged)
	
		onCharacterChanged(oldChar, doll.getCharacter())
	
func onCharacterChanged(oldChar: BaseCharacter, newChar: BaseCharacter):
	if(oldChar != null && is_instance_valid(oldChar)):
		oldChar.onBodypartChanged.disconnect(onBodypartsChanged)
	if(newChar != null):
		newChar.onBodypartChanged.connect(onBodypartsChanged)
	onBodypartsChanged()
	print("BODYPART FOLLOWER CHARACTER CHANGED")
	
func onBodypartsChanged():
	objectRefToFollow = null
	var character:BaseCharacter = doll.getCharacter()
	if(character == null):
		return
	var theBodypart:BaseBodypart = character.getBodypartByPath(bodypartPath)
	if(theBodypart == null):
		return
	if(doll.bodypartToDollPart.has(theBodypart)):
		objectRefToFollow = weakref(doll.bodypartToDollPart[theBodypart])
	_process(0.0) # Avoids the follower being out of date for one frame

func _process(_delta):
	var theObject = (objectRefToFollow.get_ref().getBodypartSlotObjectOrNull(bodypartSlot) if objectRefToFollow != null else null)
	if(theObject == null):
		if(visible):
			visible = false
			print("HIDDEN THE BODY FOLLOWER")
	else:
		if(!visible):
			visible = true
			print("SHOWING THE BODY FOLLOWER")
		
		global_transform = theObject.global_transform
