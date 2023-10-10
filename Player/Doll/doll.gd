extends CharacterBody3D
class_name Doll

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var character:BaseCharacter
var dollSkeleton:DollSkeleton
var bodypartToDollPart:Dictionary = {}

func getCharacter() -> BaseCharacter:
	return character

func setCharacter(newChar:BaseCharacter):
	character = newChar
	updateFromCharacter()
	# Add support for bodyparts being removed
	newChar.connect("onBodypartChanged", onBodypartChanged)

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
	if(dollSkeleton != null):
		dollSkeleton.queue_free()
		dollSkeleton = null

func updateSkeleton():
	var root = character.getRootBodypart()
	
	var skeletonScene = root.getSkeletonScene()
	
	if(dollSkeleton != null):
		dollSkeleton.queue_free()
		dollSkeleton = null
	
	dollSkeleton = skeletonScene.instantiate()
	add_child(dollSkeleton)

func updateFromCharacter():
	updateSkeleton()

	var root = character.getRootBodypart()
	var meshScene = root.getMeshScene()
	if(meshScene != null):
		var mesh = meshScene.instantiate()
		
		dollSkeleton.getSkeleton().add_child(mesh)
		
		mesh.setSkeleton(dollSkeleton.getSkeleton())
		
		bodypartToDollPart[root] = mesh
	
	var childParts = root.getBodyparts()
	for bodypartSlot in childParts:
		if(childParts[bodypartSlot] == null):
			continue
		var childPart:BaseBodypart = childParts[bodypartSlot]
		
		updateBodypartRecursive(root, bodypartSlot, childPart)

func onBodypartChanged(whatpart: BaseBodypart, slot: String, newpart: BaseBodypart):
	updateBodypartRecursive(whatpart, slot, newpart)

func updateBodypartRecursive(parentPart:BaseBodypart, slot:String, part:BaseBodypart):
	print(slot+" Working")
	var meshScene = part.getMeshScene()
	if(meshScene != null):
		var mesh = meshScene.instantiate()
		
		var dollPart: DollPart = bodypartToDollPart[parentPart]
		var attachObject:Node
		
		# Better check if we should attach to the doll skeleton?
		if(parentPart is BaseBodyBodypart):
			attachObject = dollSkeleton.getBodypartSlotObject(slot)
		else:
			attachObject = dollPart.getBodypartSlotObject(slot)
		
		print(slot+" Attached to ",attachObject)
		attachObject.add_child(mesh)
		#mesh.setSkeleton(dollSkeleton.getSkeleton())
		
		bodypartToDollPart[part] = mesh

		var childParts = part.getBodyparts()
		for bodypartSlot in childParts:
			if(childParts[bodypartSlot] == null):
				continue
			var childPart:BaseBodypart = childParts[bodypartSlot]
			
			updateBodypartRecursive(part, bodypartSlot, childPart)
