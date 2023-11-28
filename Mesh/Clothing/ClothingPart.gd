extends Node3D
class_name ClothingPart

var dollRef:WeakRef
var itemRef:WeakRef

var watchesBodyparts:Dictionary = {
	"root" = [],
	"head" = [BodypartSlot.Head],
}

func connectSignals():
	#var theDoll = getDoll()
	
	
	for watchID in watchesBodyparts:
		var watchPath = watchesBodyparts[watchID]
		
		var bodypart:BaseBodypart = getBodypartByPath(watchPath)
		
		if(bodypart == null):
			continue
		bodypart.onOptionChanged.connect(onBodypartOptionChanged.bind(watchID, bodypart))

func onBodypartOptionChanged(_optionID: String, _value, watchID:String, _bodypart:BaseBodypart):
	onWatchedBodypartOptionChanges(watchID, _optionID, _value)

func applyToDoll(_theDoll:Doll):
	pass

func onWatchedBodypartOptionChanges(_partID: String, _optionID: String, _value):
	print("I SEE IT ",_partID," ",_optionID)

func getDoll() -> Doll:
	if(dollRef == null):
		return null
	return dollRef.get_ref()

func getItem() -> ItemBase:
	if(itemRef == null):
		return null
	return itemRef.get_ref()

func getBodypartByPath(path:Array) -> BaseBodypart:
	var theDoll:Doll = getDoll()
	if(theDoll == null):
		return null
	
	var character:BaseCharacter = theDoll.getCharacter()
	if(character == null):
		return null

	return character.getBodypartByPath(path)

func getDollpartByPath(path:Array) -> DollPart:
	var bodypart:BaseBodypart = getBodypartByPath(path)
	if(bodypart == null):
		return null
	
	var theDoll:Doll = getDoll()
	if(theDoll == null):
		return null
	
	if(!theDoll.bodypartToDollPart.has(bodypart)):
		return null
	return theDoll.bodypartToDollPart[bodypart]

func setMeshToBodypartByPath(mesh:MeshInstance3D, path:Array):
	var theDollPart:DollPart = getDollpartByPath(path)
	if(theDollPart != null):
		var skeleton = theDollPart.getSkeleton()
		if(skeleton != null):
			mesh.skeleton = mesh.get_path_to(skeleton)

func getBodyAlphaTexturePath() -> String:
	return ""

func getBodyAlphaTexture() -> Texture2D:
	var thePath = getBodyAlphaTexturePath()
	if(thePath == ""):
		return null
	return load(thePath)

func getPartsToHide() -> Dictionary:
	return {}

func updateHiddenParts(_hiddenParts:Dictionary):
	pass
