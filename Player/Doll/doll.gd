extends CharacterBody3D
class_name Doll

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

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

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

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
		
		root.applyOptionsToDollPart(newDollPart)
		root.onOptionChanged.connect(Callable(newDollPart, "onPartOptionChanged"))
		#dollSkeleton.getSkeleton().add_child(newDollPart)
		
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
	var meshScene = part.getMeshScene()
	if(meshScene != null):
		var newDollPart:DollPart = meshScene.instantiate()
		
		var parentDollPart: DollPart = bodypartToDollPart[parentPart]
		parentDollPart.dollRef = weakref(self)
		var attachObject:Node = parentDollPart.getBodypartSlotObject(slot)
		
		print(slot+" Attached to ",attachObject)
		attachObject.add_child(newDollPart)
		
		part.applyOptionsToDollPart(newDollPart)
		part.onOptionChanged.connect(Callable(newDollPart, "onPartOptionChanged"))
		parentPart.onOptionChanged.connect(Callable(newDollPart, "onParentPartOptionChanged"))
		
		if(newDollPart.shouldBindToParentSkeleton()):
			newDollPart.setSkeleton(parentDollPart.getSkeleton())
		#mesh.setSkeleton(dollSkeleton.getSkeleton())
		
		bodypartToDollPart[part] = newDollPart

		var childParts = part.getBodyparts()
		for bodypartSlot in childParts:
			if(childParts[bodypartSlot] == null):
				continue
			var childPart:BaseBodypart = childParts[bodypartSlot]
			
			updateBodypartRecursive(part, bodypartSlot, childPart)
