extends Node3D
class_name Doll

var character:BaseCharacter
#var dollSkeleton:DollSkeleton
var bodypartToDollPart:Dictionary = {}
var itemToClothingPart:Dictionary = {}
@onready var bodyparts = $Bodyparts
@onready var clothing = $Clothing

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
	emit_signal("selectedCharacterChanged", oldChar, character)

func clear():
	for clothingPart in itemToClothingPart.values():
		clothingPart.queue_free()
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
		
		if(parentPart != null):
			var parentDollPart: DollPart = bodypartToDollPart[parentPart]
			parentDollPart.dollRef = weakref(self)
			var attachObject:Node = parentDollPart.getBodypartSlotObject(slot)
			
			#print(slot+" Attached to ",attachObject)
			attachObject.add_child(newDollPart)
		else:
			bodyparts.add_child(newDollPart)
		
		part.applyEverythingToDollPart(newDollPart)
		part.onOptionChanged.connect(Callable(newDollPart, "onPartOptionChanged"))
		if(parentPart != null):
			parentPart.onOptionChanged.connect(Callable(newDollPart, "onParentPartOptionChanged"))
		part.onBaseSkinDataOverrideChanged.connect(Callable(newDollPart, "onPartSkinDataChanged"))
		applyEverythingFromDollToDollPart(newDollPart)
		#newDollPart.applyBaseSkinData(part.getBaseSkinData()) # Everything does it
		
		#if(newDollPart.shouldBindToParentSkeleton()):
		#	newDollPart.setSkeleton(parentDollPart.getSkeleton())
		#mesh.setSkeleton(dollSkeleton.getSkeleton())
		
		bodypartToDollPart[part] = newDollPart
		
		var end = Time.get_ticks_usec()
		var worker_time = (end-start)/1000000.0
		print(slot+" Attached, Took: ",worker_time," seconds")

		var childParts = part.getBodyparts()
		for bodypartSlot in childParts:
			if(childParts[bodypartSlot] == null):
				continue
			var childPart:BaseBodypart = childParts[bodypartSlot]
			
			updateBodypartRecursive(part, bodypartSlot, childPart)

func applyEverythingFromDollToDollPart(theDollPart:DollPart):
	theDollPart.setFirstPerson(firstPerson)
	theDollPart.updateHiddenParts(getAllHiddenParts())

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
		itemMesh.itemRef = weakref(item)
		itemMesh.dollRef = weakref(self)
		addNodeToFollowBody(itemMesh, meshData["attachTo"], meshData["attachSlot"])
		itemToClothingPart[item][meshID] = itemMesh
		itemMesh.connectSignals()
		itemMesh.applyToDoll(self)
		
	updateEquippedItemsAlpha()
	return true

func addItemToDoll_OLD(item:ItemBase):
	# Probably better to pass the character into the mesh scene?
	var itemMeshScene:PackedScene = item.getMeshScene()
	
	if(itemMeshScene == null):
		return false
	
	var itemMesh:ClothingPart = itemMeshScene.instantiate()
	itemMesh.itemRef = weakref(item)
	itemMesh.dollRef = weakref(self)
	add_child(itemMesh)
	itemToClothingPart[item] = itemMesh
	itemMesh.connectSignals()
	itemMesh.applyToDoll(self)
	
	updateEquippedItemsAlpha()
	
	return true

func getAllHiddenParts() -> Dictionary:
	if(true):
		return {} # Do this in items somehow?
	var hiddenBodyParts = {}
	for clothingPart in itemToClothingPart.values():
		var hiddenParts = clothingPart.getPartsToHide()
		for thePart in hiddenParts:
			if(hiddenParts[thePart]):
				hiddenBodyParts[thePart] = true
	return hiddenBodyParts

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
	
	var hiddenBodyParts = getAllHiddenParts()
	
	for clothingPart in allClothingItems:
		clothingPart.updateHiddenParts(hiddenBodyParts)
	for dollPart in bodypartToDollPart.values():
		dollPart.updateHiddenParts(hiddenBodyParts)

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
	print("INVENTORY DOLL EVENT: "+event.getReadableInfo())
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
