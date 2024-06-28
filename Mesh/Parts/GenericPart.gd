extends Node3D
class_name GenericPart

var dollRef:WeakRef
var partRef:WeakRef

var firstPerson:bool = false

func _init():
	pass

func getDoll() -> Doll:
	if(dollRef == null):
		return null
	return dollRef.get_ref()

func getPart() -> RefWithOptions:
	if(partRef == null):
		return null
	return partRef.get_ref()

func getOptionValue(valueID: String, defaultValue = null):
	var thePart:RefWithOptions = getPart()
	if(thePart == null):
		return defaultValue
	return thePart.getOptionValue(valueID, defaultValue)

func applyOption(_optionID: String, _value):
	pass

func onPartOptionChanged(_optionID, _value):
	applyOption(_optionID, _value)

func setBlendshape(mesh: MeshInstance3D, blendShapeID: String, val: float):
	if(mesh == null):
		return
	var blendShapeIndex = mesh.find_blend_shape_by_name(blendShapeID)
	if(blendShapeIndex >= 0):
		mesh.set_blend_shape_value(blendShapeIndex, val)

func playAnim(_dollAnim:String, _howFast:float = 1.0):
	pass

func setFirstPerson(newFirstPerson:bool) -> void:
	if(firstPerson != newFirstPerson):
		firstPerson = newFirstPerson
		onFirstPersonChange(firstPerson)
		
func onFirstPersonChange(_newFirstPerson:bool) -> void:
	pass

func applyPartTags(_partTags:Dictionary):
	pass

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
