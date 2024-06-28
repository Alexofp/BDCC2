extends Node3D
class_name Doll

var character:BaseCharacter
#var dollSkeleton:DollSkeleton
var bodypartToDollPart:Dictionary = {}
var itemToClothingPart:Dictionary = {}
@onready var bodyparts = $Bodyparts
@onready var clothing = $Clothing

var partTagsDirtyFlag:bool = false
var cachedPartTags:Dictionary = {}
signal onPartTagsUpdated

signal selectedCharacterChanged(oldChar, newChar)

var firstPerson:bool = false

func getCharacter() -> BaseCharacter:
	return character

func setCharacter(newChar:BaseCharacter):
	if(character != null && is_instance_valid(character)):
		Util.remove_all_signals_with_target(character, self)
	var oldChar = character
	character = newChar
	updateFromCharacter()
	# Add support for bodyparts being removed
	newChar.connect("onRootChanged", onRootChanged)
	newChar.connect("onBodypartAdded", onBodypartChanged)
	newChar.connect("onBodypartRemoved", onBodypartRemoved)
	newChar.connect("onBaseSkinDataChanged", onBaseCharacterBaseSkinDataChanged)
	newChar.connect("onInventoryChanged", onInventoryChangedCallback)
	
	newChar.connect("onExtraPartAdded", onExtraPartAdded)
	newChar.connect("onExtraPartRemoved", onExtraPartRemoved)
	newChar.connect("onPartTagsNeedUpdate", markPartTagsToUpdate)
	emit_signal("selectedCharacterChanged", oldChar, character)

func clear():
	for clothingPart in itemToClothingPart.values():
		for thingToQueue in clothingPart.values():
			thingToQueue.queue_free()
	itemToClothingPart = {}
	for dollpart in bodypartToDollPart.values():
		dollpart.queue_free()
	bodypartToDollPart.clear()

func updateFromCharacter():
	clear()
	
	var root = character.getRootBodypart()
	updateBodypartRecursive(null, "root", root)
		
	updateEquippedItemsFromCharacter()

func onRootChanged(_newroot: BaseBodyBodypart):
	updateFromCharacter()

func onBodypartChanged(whatpart: BaseBodypart, slot: String, newpart: BaseBodypart):
	updateBodypartRecursive(whatpart, slot, newpart)
	
	updateEquippedItemsFromCharacter()

func onBodypartRemoved(_whatpart: BaseBodypart, slot: String, removedpart: BaseBodypart):
	if(bodypartToDollPart.has(removedpart)):
		var dollPartToRemove = bodypartToDollPart[removedpart]
		print(slot+" Removed ",dollPartToRemove)
		bodypartToDollPart.erase(removedpart)
		dollPartToRemove.queue_free()
	
	updateEquippedItemsFromCharacter()
	
func updateBodypartRecursive(parentPart:BaseBodypart, slot:String, part:BaseBodypart):
	var start = Time.get_ticks_usec()
	var meshScene = part.getMeshScene()
	if(meshScene != null):
		var newDollPart:DollPart = meshScene.instantiate()
		newDollPart.dollRef = weakref(self)
		
		if(parentPart != null):
			var parentDollPart: DollPart = bodypartToDollPart[parentPart]
			var attachObject:Node = parentDollPart.getBodypartSlotObject(slot)
			
			#print(slot+" Attached to ",attachObject)
			attachObject.add_child(newDollPart)
		else:
			bodyparts.add_child(newDollPart)
		
		part.applyEverythingToPart(newDollPart)
		part.onOptionChanged.connect(Callable(newDollPart, "onPartOptionChanged"))
		if(!part.onOptionChanged.is_connected(onPartOptionChanged.bind(part))):
			part.onOptionChanged.connect(onPartOptionChanged.bind(part))
		if(parentPart != null):
			parentPart.onOptionChanged.connect(Callable(newDollPart, "onParentPartOptionChanged"))
		part.onBaseSkinDataOverrideChanged.connect(Callable(newDollPart, "onPartSkinDataChanged"))
		applyEverythingFromDollToPart(newDollPart)
		#newDollPart.applyBaseSkinData(part.getBaseSkinData()) # Everything does it
		
		#if(newDollPart.shouldBindToParentSkeleton()):
		#	newDollPart.setSkeleton(parentDollPart.getSkeleton())
		#mesh.setSkeleton(dollSkeleton.getSkeleton())
		
		bodypartToDollPart[part] = newDollPart
		
		var extraParts = part.getExtraParts()
		for extraPartA in extraParts:
			var extraPart:BodypartExtra = extraPartA
			
			addExtraToDollpart(extraPart, newDollPart)
		
		var end = Time.get_ticks_usec()
		var worker_time = (end-start)/1000000.0
		print(slot+" Attached, Took: ",worker_time," seconds")

		var childParts = part.getBodyparts()
		for bodypartSlot in childParts:
			if(childParts[bodypartSlot] == null):
				continue
			var childPart:BaseBodypart = childParts[bodypartSlot]
			
			updateBodypartRecursive(part, bodypartSlot, childPart)

func onExtraPartAdded(bodypart: BaseBodypart, newextra: BodypartExtra):
	addExtraToDollpart(newextra, bodypartToDollPart[bodypart])

func onExtraPartRemoved(bodypart: BaseBodypart, extraremoved: BodypartExtra):
	bodypartToDollPart[bodypart].extraToExtraPart[extraremoved].queue_free()

func addExtraToDollpart(extraPart:BodypartExtra, newDollPart:DollPart):
	var extraMeshPath:String = extraPart.getMeshPath()
	var extraMesh:ExtraPart = load(extraMeshPath).instantiate()
	extraMesh.dollRef = weakref(self)
	
	var attachObject:Node = newDollPart.getBodypartSlotObject(extraPart.attachToSlot)
	attachObject.add_child(extraMesh)
	extraPart.applyEverythingToPart(extraMesh)
	extraPart.onOptionChanged.connect(Callable(extraMesh, "onPartOptionChanged"))
	extraMesh.applyToDoll(self, newDollPart)
	applyEverythingFromDollToPart(extraMesh)
	newDollPart.extraToExtraPart[extraPart] = extraMesh

func onPartOptionChanged(optionID, newValue, bodypart:BaseBodypart):
	for meshes in itemToClothingPart.values():
		for clothingpart in meshes.values():
			for watchID in clothingpart.watchesBodyparts:
				var bodyparthPath = clothingpart.watchesBodyparts[watchID]
				
				if(getBodypartByPath(bodyparthPath) == bodypart):
					#for optionID in bodypart.getOptions():
					clothingpart.onBodypartOptionChanged(optionID, newValue, watchID, bodypart)

func applyEverythingFromDollToPart(thePart:GenericPart):
	thePart.setFirstPerson(firstPerson)
	#thePart.updateHiddenParts(getAllHiddenParts())
	markPartTagsToUpdate()

func getDoll() -> Doll:
	return self

func getMainSkeleton() -> Skeleton3D:
	return $BodySkeleton.getSkeleton()
	
func getBodySkeleton():
	return $BodySkeleton

func playAnim(dollAnim:String, howFast:float = 1.0):
	for dollPart in bodypartToDollPart.values():
		if(dollPart == null):
			continue
		dollPart.playAnim(dollAnim, howFast)

func onBaseCharacterBaseSkinDataChanged(_newData : BaseSkinData):
	for bodypart in getCharacter().getAllBodyparts():
		if(!bodypartToDollPart.has(bodypart)):
			continue
		if(bodypart.baseSkinDataOverride != null):
			continue
		var dollPart:DollPart = bodypartToDollPart[bodypart]
		
		dollPart.applyBaseSkinData(bodypart.getBaseSkinData())
		
func setFirstPerson(newFirstPerson:bool) -> void:
	if(firstPerson != newFirstPerson):
		firstPerson = newFirstPerson
		
		for dollPart in bodypartToDollPart.values():
			dollPart.setFirstPerson(firstPerson)

func isFirstPerson() -> bool:
	return firstPerson

func removeItemFromDoll(item:ItemBase):
	if(!itemToClothingPart.has(item)):
		return false
	var clothingPartsWithIds = itemToClothingPart[item]
	for meshID in clothingPartsWithIds:
		removeNodeFromFollowingBody(clothingPartsWithIds[meshID])
	updateEquippedItemsAlpha()
	itemToClothingPart.erase(item)
	return true

func addItemToDoll(item:ItemBase):
	var itemMeshStructure:Dictionary = item.getMeshStructure(getCharacter())
	
		#"hat": {
			#"attachTo": [BodypartSlot.Head],
			#"attachSlot": "Hat",
			#"path": "res://Mesh/Clothing/TestHat/TestHat.tscn",
		#}
	if(itemToClothingPart.has(item)):
		removeItemFromDoll(item)
	itemToClothingPart[item] = {}
	for meshID in itemMeshStructure:
		var meshData = itemMeshStructure[meshID]
		
		var itemMesh:ClothingPart = load(meshData["path"]).instantiate()
		itemMesh.dollRef = weakref(self)
		item.applyEverythingToPart(itemMesh)
		item.onOptionChanged.connect(Callable(itemMesh, "onPartOptionChanged"))
		addNodeToFollowBody(itemMesh, meshData["attachTo"], meshData["attachSlot"])
		itemToClothingPart[item][meshID] = itemMesh
		#itemMesh.connectSignals()
		itemMesh.applyToDoll(self, getDollpartByPath(meshData["attachTo"]))
		applyEverythingFromDollToPart(itemMesh)
		
		# Applying all of the watched options of this item
		for bodypartWatchName in itemMesh.watchesBodyparts:
			var bodypartPath = itemMesh.watchesBodyparts[bodypartWatchName]
			var theBodypart:BaseBodypart = getBodypartByPath(bodypartPath)
			if(theBodypart == null):
				continue
			for optionID in theBodypart.getOptions():
				itemMesh.onBodypartOptionChanged(optionID, theBodypart.getOptionValue(optionID), bodypartWatchName, theBodypart)
		
	updateEquippedItemsAlpha()
	return true

#func reapplyAllClothingToDoll():
	#pass

func markPartTagsToUpdate():
	partTagsDirtyFlag = true

func updateAllPartTags():
	partTagsDirtyFlag = false
	var newCache = {}
	
	var allBodyparts = getCharacter().getAllBodyparts()
	for part in allBodyparts:
		var hiddenParts = part.getPartTags()
		for thePart in hiddenParts:
			if(hiddenParts[thePart]):
				newCache[thePart] = true
	
	var allItems = getCharacter().getInventory().getEquippedItems().values()
	for theItem in allItems:
		var hiddenParts = theItem.getPartTags()
		for thePart in hiddenParts:
			if(hiddenParts[thePart]):
				newCache[thePart] = true
	
	cachedPartTags = newCache
	
	emit_signal("onPartTagsUpdated")
	
	for dollPart in bodypartToDollPart.values():
		if(dollPart == null):
			continue
		dollPart.applyPartTags(cachedPartTags)
	for meshes in itemToClothingPart.values():
		for clothingpart in meshes.values():
			clothingpart.applyPartTags(cachedPartTags)

func hasPartTag(partTag:String) -> bool:
	if(cachedPartTags.has(partTag)):
		return true
	return false

func updateEquippedItemsAlpha():
	if(true):
		return # Check items themselves for alpha?
	var allClothingItems = itemToClothingPart.values()
	
	var root:DollPart = getDollpartByPath([])
	if(root != null):
		var allAlphas = []
		for clothingPart in allClothingItems:
			var alphaTexture = clothingPart.getBodyAlphaTexture()
			if(alphaTexture != null):
				allAlphas.append(alphaTexture)
		root.updateAlphas(allAlphas)
	
	#var hiddenBodyParts = getAllHiddenParts()
	
	#for clothingPart in allClothingItems:
	#	clothingPart.updateHiddenParts(hiddenBodyParts)
	#for dollPart in bodypartToDollPart.values():
	#	dollPart.updateHiddenParts(hiddenBodyParts)

func updateEquippedItemsFromCharacter():
	for clothingItem in itemToClothingPart.keys():
		removeItemFromDoll(clothingItem)
	itemToClothingPart = {}
	
	var inventory:Inventory = character.getInventory()
	var equippedItems:Dictionary = inventory.getEquippedItems()
	for inventorySlot in equippedItems:
		var item:ItemBase = equippedItems[inventorySlot]
		addItemToDoll(item)


func onInventoryChangedCallback(event: InventoryChangedEvent):
	#print("INVENTORY DOLL EVENT: "+event.getReadableInfo())
	#emit_signal("onInventoryChanged", event)
	
	if(event.eventType == InventoryChangedEvent.ItemUnequipped):
		var theItem:ItemBase = event.item
		removeItemFromDoll(theItem)
	elif(event.eventType == InventoryChangedEvent.ItemEquipped):
		var item:ItemBase = event.item
		addItemToDoll(item)

#var allFollowers = []
var bodypartFollowerScene = preload("res://Player/Doll/bodypart_follower.tscn")
func addNodeToFollowBody(theNode:Node3D, bodypartPath:Array, bodypartSlot:String):
	var newFollower = bodypartFollowerScene.instantiate()
	clothing.add_child(newFollower)
	newFollower.setToFollow(self, bodypartPath, bodypartSlot)
	newFollower.add_child(theNode)

func removeNodeFromFollowingBody(theNode:Node3D):
	theNode.get_parent().queue_free()

func getBodypartByPath(path:Array) -> BaseBodypart:
	var theCharacter:BaseCharacter = getCharacter()
	if(theCharacter == null):
		return null

	return theCharacter.getBodypartByPath(path)

func getDollpartByPath(path:Array) -> DollPart:
	var bodypart:BaseBodypart = getBodypartByPath(path)
	if(bodypart == null):
		return null
	
	if(!bodypartToDollPart.has(bodypart)):
		return null
	return bodypartToDollPart[bodypart]

func _process(_delta):
	if(partTagsDirtyFlag):
		partTagsDirtyFlag = false
		updateAllPartTags()
