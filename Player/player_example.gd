extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var mat: StandardMaterial3D

func _ready():
	if(true):
		return
	var time = Time.get_ticks_msec()
	var bodyImage = load("res://Mesh/BodyColorResource.png")
	bodyImage.convert(Image.FORMAT_RGBA8)
	var decalImage = load("res://Mesh/DecalTest.png")
	
	print(bodyImage.get_format())
	print(decalImage.get_format())
	bodyImage.blend_rect(decalImage, Rect2i(0, 0, 2048, 2048), Vector2i(0, 0))
	bodyImage.blend_rect(decalImage, Rect2i(0, 0, 2048, 2048), Vector2i(0, 0))
	bodyImage.blend_rect(decalImage, Rect2i(0, 0, 2048, 2048), Vector2i(0, 0))
	bodyImage.blend_rect(decalImage, Rect2i(0, 0, 2048, 2048), Vector2i(0, 0))
	bodyImage.blend_rect(decalImage, Rect2i(0, 0, 2048, 2048), Vector2i(0, 0))
	bodyImage.blend_rect(decalImage, Rect2i(0, 0, 2048, 2048), Vector2i(0, 0))
	
	$TextureRect.texture = ImageTexture.create_from_image(bodyImage)
	
	mat.albedo_texture = $TextureRect.texture
	
	var newTime = Time.get_ticks_msec()
	print(float(newTime - time)/1000.0, " seconds")

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
