extends Node3D
class_name Doll

var character:BaseCharacter
#var dollSkeleton:DollSkeleton
var bodypartToDollPart:Dictionary = {}

func getCharacter() -> BaseCharacter:
	return character

func setCharacter(newChar:BaseCharacter):
	character = newChar
	updateFromCharacter()
	# Add support for bodyparts being removed
	newChar.connect("onBodypartAdded", onBodypartChanged)
	newChar.connect("onBodypartRemoved", onBodypartRemoved)
	newChar.connect("onBaseSkinDataChanged", onBaseCharacterBaseSkinDataChanged)

func clear():
	pass
	#if(dollSkeleton != null):
	#	dollSkeleton.queue_free()
	#	dollSkeleton = null

func updateSkeleton():
	var root = character.getRootBodypart()
	
	#var skeletonScene = root.getSkeletonScene()
	
	#if(dollSkeleton != null):
	#	dollSkeleton.queue_free()
	#	dollSkeleton = null
	
	#dollSkeleton = skeletonScene.instantiate()
	#add_child(dollSkeleton)

func updateFromCharacter():
	updateSkeleton()

	var root = character.getRootBodypart()
	var meshScene = root.getMeshScene()
	if(meshScene != null):
		var newDollPart = meshScene.instantiate()
		
		add_child(newDollPart)
		
		root.applyEverythingToDollPart(newDollPart)
		root.onOptionChanged.connect(Callable(newDollPart, "onPartOptionChanged"))
		root.onSkinOptionChanged.connect(Callable(newDollPart, "onPartSkinOptionChanged"))
		root.onBaseSkinDataOverrideChanged.connect(Callable(newDollPart, "onPartSkinDataChanged"))
		#dollSkeleton.getSkeleton().add_child(newDollPart)
		#newDollPart.applyBaseSkinData(root.getBaseSkinData())
		
		#newDollPart.setSkeleton(dollSkeleton.getSkeleton())
		
		bodypartToDollPart[root] = newDollPart
	
	var childParts = root.getBodyparts()
	for bodypartSlot in childParts:
		if(childParts[bodypartSlot] == null):
			continue
		var childPart:BaseBodypart = childParts[bodypartSlot]
		
		updateBodypartRecursive(root, bodypartSlot, childPart)

func onBodypartChanged(whatpart: BaseBodypart, slot: String, newpart: BaseBodypart):
	updateBodypartRecursive(whatpart, slot, newpart)

func onBodypartRemoved(whatpart: BaseBodypart, slot: String, removedpart: BaseBodypart):
	if(bodypartToDollPart.has(removedpart)):
		var dollPartToRemove = bodypartToDollPart[removedpart]
		print(slot+" Removed ",dollPartToRemove)
		bodypartToDollPart.erase(removedpart)
		dollPartToRemove.queue_free()
	
func updateBodypartRecursive(parentPart:BaseBodypart, slot:String, part:BaseBodypart):
	var start = Time.get_ticks_usec()
	var meshScene = part.getMeshScene()
	if(meshScene != null):
		var newDollPart:DollPart = meshScene.instantiate()
		
		var parentDollPart: DollPart = bodypartToDollPart[parentPart]
		parentDollPart.dollRef = weakref(self)
		var attachObject:Node = parentDollPart.getBodypartSlotObject(slot)
		
		#print(slot+" Attached to ",attachObject)
		attachObject.add_child(newDollPart)
		
		part.applyEverythingToDollPart(newDollPart)
		part.onOptionChanged.connect(Callable(newDollPart, "onPartOptionChanged"))
		part.onSkinOptionChanged.connect(Callable(newDollPart, "onPartSkinOptionChanged"))
		parentPart.onOptionChanged.connect(Callable(newDollPart, "onParentPartOptionChanged"))
		part.onBaseSkinDataOverrideChanged.connect(Callable(newDollPart, "onPartSkinDataChanged"))
		#newDollPart.applyBaseSkinData(part.getBaseSkinData()) # Everything does it
		
		if(newDollPart.shouldBindToParentSkeleton()):
			newDollPart.setSkeleton(parentDollPart.getSkeleton())
		#mesh.setSkeleton(dollSkeleton.getSkeleton())
		
		bodypartToDollPart[part] = newDollPart
		
		var end = Time.get_ticks_usec()
		var worker_time = (end-start)/1000000.0
		print(slot+" Attached to ",attachObject," Took: ",worker_time," seconds")

		var childParts = part.getBodyparts()
		for bodypartSlot in childParts:
			if(childParts[bodypartSlot] == null):
				continue
			var childPart:BaseBodypart = childParts[bodypartSlot]
			
			updateBodypartRecursive(part, bodypartSlot, childPart)

func getDoll() -> Doll:
	return self

func playAnim(dollAnim:String, howFast:float = 1.0):
	for dollPart in bodypartToDollPart.values():
		if(dollPart == null):
			continue
		dollPart.playAnim(dollAnim, howFast)

func onBaseCharacterBaseSkinDataChanged(newData : BaseSkinData):
	for bodypart in getCharacter().getAllBodyparts():
		if(!bodypartToDollPart.has(bodypart)):
			continue
		if(bodypart.baseSkinDataOverride != null):
			continue
		var dollPart:DollPart = bodypartToDollPart[bodypart]
		
		dollPart.applyBaseSkinData(bodypart.getBaseSkinData())
