extends CharacterBody3D
class_name PlayerEditor

@onready var flashlight_light: SpotLight3D = %FlashlightLight
@onready var omni_flashlight: OmniLight3D = %OmniFlashlight

@onready var head_pivot: Node3D = $HeadPivot
@onready var stand_collision_shape_3d: CollisionShape3D = $StandCollisionShape3D
@onready var crotch_collision_shape_3d: CollisionShape3D = $CrotchCollisionShape3D
@onready var uncrouch_area: Area3D = $UncrouchArea
@onready var assetStash: PCEditorAssetStash = $PCEditorAssetStash

@onready var ui_canvas_layer: CanvasLayer = %UICanvasLayer
@onready var tool_rich_text: RichTextLabel = %ToolRichText

@onready var editor_canvas_layer: CanvasLayer = %EditorCanvasLayer
@onready var prop_item_list: ItemList = %PropItemList
@onready var category_buttons_list: HFlowContainer = %CategoryButtonsList
@onready var toolVarList: VarList = %ToolVarList
@onready var prop_var_list: VarList = %PropVarList
@onready var reset_prop_settings_button: Button = %ResetPropSettingsButton

@onready var camera_3d: Camera3D = %Camera3D
@onready var save_file_dialog: FileDialog = %SaveFileDialog
@onready var open_file_dialog: FileDialog = %OpenFileDialog
@onready var messages_rich_text: RichTextLabel = %MessagesRichText

@onready var open_template_dialog: FileDialog = %OpenTemplateDialog
@onready var my_template_dialog: ConfirmationDialog = %MyTemplateDialog
@onready var template_item_list: ItemList = %TemplateItemList


var currentMapPath:String = ""
var messagesList:Array = []

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SPRINT_SPEED = 10.0
const WALK_SPEED = 2.5
const CROUCH_SPEED = 2.5

const MOUSE_SENSETIVITY = 0.2
var mouseLocked:bool = true
var rotation_smoothing: float = 1.0

var isInNoclip:bool = false

var undoStack:Array = []
var redoStack:Array = []
var currentTick:int = 0

const dirBase = "user://PCEditor/"
var currentCategory:String = ""
var selectedProp:PCEditorProp
var selectedPropSettings:Dictionary = {}
var selectedPropSettingsValues:Dictionary = {}
var savedSettingsByID:Dictionary = {}

var propEntries:Dictionary = {}

var lastUniqueID:int = 0

var savedRichToolText:String = ""

var foundTemplates:Array = []

func _init():
	DirAccess.make_dir_absolute(dirBase)
	DirAccess.make_dir_absolute(dirBase.path_join("Maps/"))

func _ready():
	readyUI()
	setSelectedTool("0NoTool")
	showMessage("Q - Menu", 5.0)
	showMessage("V - Noclip", 5.0)
	toggleBuildingPlatform.call_deferred()
	assetStash.messenger = self
	updateTemplateList()
	
	## Uncomment to auto-load the cellblock template
	#_on_open_file_dialog_file_selected.call_deferred("res://Game/IngameEditor/Templates/genblock.res", true)
	pass
	
var savedEscapePressed:bool = false
func updateMouseLock() -> void:
	var isEscapePressed:bool = Input.is_physical_key_pressed(KEY_ESCAPE) || Input.is_physical_key_pressed(KEY_Q)
	if(isEscapePressed && !savedEscapePressed):
		mouseLocked = !mouseLocked
		if(!mouseLocked):
			updateToolVars()
	savedEscapePressed = isEscapePressed
	
	var finalMouseLocked:bool = mouseLocked
	
	var theTool:=getCurrentTool()
	var shouldUnlockByTool:bool = false
	if(theTool != null && theTool.shouldUnlockMouse()):
		shouldUnlockByTool = true
	if(finalMouseLocked && !shouldUnlockByTool && !open_file_dialog.visible && !save_file_dialog.visible):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	editor_canvas_layer.visible = !finalMouseLocked

var headtween:Tween
var savedIsCrouching:bool = false
func updateCrouch(forceUpdate:bool = false) -> void:
	var isCrouching:bool = Input.is_physical_key_pressed(KEY_CTRL)
	if(savedIsCrouching && !isCrouching && !isInNoclip):
		if(uncrouch_area.get_overlapping_bodies().size() > 1):
			isCrouching = true
	
	if(isCrouching != savedIsCrouching || forceUpdate):
		crotch_collision_shape_3d.disabled = !isCrouching || isInNoclip
		stand_collision_shape_3d.disabled = isCrouching || isInNoclip
		
		if(headtween):
			headtween.kill()
		headtween = create_tween()
		if(isCrouching && !isInNoclip):
			headtween.tween_property(head_pivot, "position", Vector3(0.0, 0.6, 0.0), 0.2).set_trans(Tween.TRANS_CUBIC)
		else:
			headtween.tween_property(head_pivot, "position", Vector3(0.0, 1.6, 0.0), 0.2).set_trans(Tween.TRANS_CUBIC)
	savedIsCrouching = isCrouching


func processCameraSmoothing(_delta:float) -> void:
	# Smooth the current rotation towards the target rotation
	current_yaw = lerp_angle(current_yaw, target_yaw, rotation_smoothing)
	current_pitch = lerp_angle(current_pitch, target_pitch, rotation_smoothing)

	# Apply the smoothed rotation to the player and camera
	rotation.y = (current_yaw)
	head_pivot.rotation.x = current_pitch
	
	if(Input.is_key_pressed(KEY_TAB)):
		camera_3d.fov = 10
	else:
		camera_3d.fov = 75

func _process(_delta: float) -> void:
	updateMouseLock()
	processCameraSmoothing(_delta)
	
	processMessagesList(_delta)
	processUI(_delta)
	processPreview()
	
	var newToolText:String = ""
	
	var theTool:=getCurrentTool()
	if(theTool != null):
		theTool.process(_delta, self)
		
		newToolText = theTool.getText()
	
	if(savedRichToolText != newToolText):
		savedRichToolText = newToolText
		tool_rich_text.text = newToolText
	
	currentTick += 1

var target_yaw: float = 0.0
var target_pitch: float = 0.0
var current_yaw: float = 0.0
var current_pitch: float = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if(event is InputEventMouseButton):
		if(event.is_pressed() && !isMenuOpened()):
			if(event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
				var theTool = getCurrentTool()
				if(theTool != null):
					theTool.onMouseWheel(false)
			if(event.button_index == MOUSE_BUTTON_WHEEL_UP):
				var theTool = getCurrentTool()
				if(theTool != null):
					theTool.onMouseWheel(true)
	if(event is InputEventMouseMotion):
		if(mouseLocked):
			var theTool := getCurrentTool()
			if(theTool != null && theTool.shouldFreezeCameraRotation()):
				theTool.onCapturedMouseMotion(event)
				return
				
			target_yaw -= deg_to_rad(event.relative.x * MOUSE_SENSETIVITY)
			target_pitch -= deg_to_rad(event.relative.y * MOUSE_SENSETIVITY)
			target_pitch = clamp(target_pitch, deg_to_rad(-90.0), deg_to_rad(90.0))
				
			#rotate_y(-deg_to_rad(event.relative.x * MOUSE_SENSETIVITY))
			#head_pivot.rotate_x(-deg_to_rad(event.relative.y * MOUSE_SENSETIVITY))
			#head_pivot.rotation.x = clamp(head_pivot.rotation.x, deg_to_rad(-90.0), deg_to_rad(90.0))
	if(event is InputEventKey && event.is_pressed()):
		if(event.physical_keycode == KEY_V):
			isInNoclip = !isInNoclip
			updateCrouch(true)
		if(event.physical_keycode == KEY_BACKSLASH):
			if(rotation_smoothing < 1.0):
				rotation_smoothing = 1.0
			else:
				rotation_smoothing = 0.2
		if(event.physical_keycode == KEY_F):
			toggleFlashlight()
		#if(event.physical_keycode == KEY_S && event.ctrl_pressed):
		if(event.physical_keycode in [KEY_F5, KEY_F1]):
			_on_file_id_pressed(1)
		if(event.physical_keycode in [KEY_F2, KEY_F9]):
			_on_file_id_pressed(2)
		if(event.physical_keycode == KEY_R && event.ctrl_pressed):
			resetGlobalIllumination()
		for toolID in tools:
			if(event.physical_keycode == tools[toolID].getHotkey()):
				if(toolID == selectedTool):
					setSelectedTool("0NoTool")
					showMessage("Tool deselected", 1.0)
				else:
					setSelectedTool(toolID)
					showMessage("Tool: "+toolID, 1.0)
				updateToolList()
				get_viewport().set_input_as_handled()
	if(event is InputEventMouseButton):
		if(event.is_pressed() && event.button_index == MOUSE_BUTTON_LEFT):
			if(!isMenuOpened()):
				onApplyTool()
		if(event.is_pressed() && event.button_index == MOUSE_BUTTON_RIGHT):
			if(!isMenuOpened()):
				onApplyAltTool()
	if(event is InputEventKey && event.is_pressed()):
		if(event.physical_keycode == KEY_Z && event.ctrl_pressed):
			if(!event.shift_pressed):
				doUndo()
			else:
				doRedo()
		elif(event.physical_keycode == KEY_Y && event.ctrl_pressed):
			doRedo()
		else:
			var theTool := getCurrentTool()
			if(theTool != null):
				theTool.onKeyPressed(event.physical_keycode, event)

func isMenuOpened() -> bool:
	return editor_canvas_layer.visible

func _physics_process(delta: float) -> void:
	updateCrouch()
	
	# Add the gravity.
	if !isInNoclip && !is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	if Input.is_physical_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var isSprinting:bool = Input.is_physical_key_pressed(KEY_SHIFT)
	var isWalking:bool = Input.is_physical_key_pressed(KEY_ALT)
	var isCrouching:bool = savedIsCrouching
	
	var currentSpeed:float = SPEED if !isSprinting else SPRINT_SPEED
	if(isWalking):
		currentSpeed = WALK_SPEED
	if(isCrouching):
		currentSpeed = CROUCH_SPEED
		if(isWalking):
			currentSpeed *= 0.2

	var wPressed:bool = Input.is_physical_key_pressed(KEY_W)
	var sPressed:bool = Input.is_physical_key_pressed(KEY_S)
	var aPressed:bool = Input.is_physical_key_pressed(KEY_A)
	var dPressed:bool = Input.is_physical_key_pressed(KEY_D)
	if(save_file_dialog.visible || open_file_dialog.visible):
		wPressed = false
		sPressed = false
		aPressed = false
		dPressed = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Vector2()#Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	input_dir.x = -float(aPressed) + float(dPressed)
	input_dir.y = -float(wPressed) + float(sPressed)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if(isInNoclip):
		direction = (transform.basis * head_pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * currentSpeed
		if(isInNoclip):
			velocity.y = direction.y * currentSpeed
		velocity.z = direction.z * currentSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		if(isInNoclip):
			velocity.y = move_toward(velocity.y, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)

	move_and_slide()

func updateTemplateList():
	template_item_list.clear()
	foundTemplates.clear()
	
	var thePath:String = "res://Game/IngameEditor/Templates/"
	var dir = DirAccess.open(thePath)
	if(dir):
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			else:
				var final_path:String = thePath.path_join(file_name)
				template_item_list.add_item(final_path.get_file())
				foundTemplates.append(final_path)
				#var theScript = load(final_path)
				#var theCommand = theScript.new()
				#commands[theCommand.id] = theScript
			file_name = dir.get_next()

@onready var tool_item_list: ItemList = %ToolItemList
@onready var editor_ui: Control = %EditorUI

var commands:Dictionary = {}
func updateCommandsDict():
	commands.clear()
	
	var thePath:String = "res://Game/IngameEditor/Commands/"
	var dir = DirAccess.open(thePath)
	if(dir):
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			else:
				var final_path:String = thePath.path_join(file_name)
				if(final_path.get_extension() != "gd"):
					file_name = dir.get_next()
					continue
				
				var theScript = load(final_path)
				var theCommand = theScript.new()
				commands[theCommand.id] = theScript
			file_name = dir.get_next()

func createCommand(_theID:String) -> PcEditorCommandBase:
	if(!commands.has(_theID)):
		return null
	var newCommand:PcEditorCommandBase = commands[_theID].new()
	newCommand.setPC(self)
	return newCommand

func doCommand(_theID:String, _args:Dictionary = {}):
	var theCommand := createCommand(_theID)
	if(theCommand == null):
		return null
	theCommand.tick = currentTick
	theCommand.do(_args)
	undoStack.append(theCommand)
	redoStack.clear()
	return theCommand

func canUndo() -> bool:
	return !undoStack.is_empty()

func doUndo():
	if(!canUndo()):
		return
	var latestTick:int = undoStack.back().tick
	
	while(!undoStack.is_empty()):
		var theCommand:PcEditorCommandBase = undoStack.back()
		if(theCommand.tick == latestTick):
			theCommand.undo()
			undoStack.pop_back()
			theCommand.tick = currentTick
			redoStack.push_back(theCommand)
		else:
			break

func canRedo():
	return !redoStack.is_empty()

func doRedo():
	if(!canRedo()):
		return
	var latestTick:int = redoStack.back().tick
	
	while(!redoStack.is_empty()):
		var theCommand:PcEditorCommandBase = redoStack.back()
		if(theCommand.tick == latestTick):
			theCommand.redo()
			redoStack.pop_back()
			theCommand.tick = currentTick
			undoStack.push_back(theCommand)
		else:
			break

var tools:Dictionary = {
	#"nothing": {
		#name = "No tool",
	#},
	#"creator": {
		#name = "Creator",
	#},
	#"deleter": {
		#name = "Deleter",
	#},
}
var selectedTool:String = ""

func updateToolsDict():
	tools.clear()
	
	var thePath:String = "res://Game/IngameEditor/Tools/"
	var dir = DirAccess.open(thePath)
	if(dir):
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			else:
				var final_path:String = thePath.path_join(file_name)
				if(final_path.get_extension() != "gd"):
					file_name = dir.get_next()
					continue
				
				var theScript = load(final_path)
				var theTool = theScript.new()
				tools[theTool.id] = theTool
				theTool.setPC(self)
				if(selectedTool == ""):
					selectedTool = theTool.id
			file_name = dir.get_next()

func readyUI():
	updateCommandsDict()
	if(currentCategory == "" && !assetStash.categories.is_empty()):
		currentCategory = assetStash.categories.keys()[0]
	updateProps()
	
	updateToolsDict()
	updateToolList()

func updateToolList():
	tool_item_list.clear()
	
	var _i:int = 0
	for toolID in tools:
		var thetool:PCEditorToolBase = tools[toolID]
		
		tool_item_list.add_item(thetool.getName())
		if(selectedTool == toolID):
			tool_item_list.select(_i)
		
		_i += 1

func _on_tool_item_list_item_selected(index: int) -> void:
	setSelectedTool(tools.keys()[index])

func setSelectedTool(toolID:String):
	if(!tools.has(toolID)):
		printerr("Trying to use a non-existant tool: "+str(toolID))
		return
	if(toolID == selectedTool):
		return
	var currentTool := getCurrentTool()
	if(currentTool != null):
		currentTool.onDeselect(self)
	selectedTool = toolID
	var newCurrentTool := getCurrentTool()
	newCurrentTool.onSelect(self)
	
	toolVarList.setVars(newCurrentTool.getSettings())

func updateToolVars():
	var theTool:=getCurrentTool()
	if(theTool != null):
		toolVarList.setVars(theTool.getSettings())

func getCurrentTool() -> PCEditorToolBase:
	if(!tools.has(selectedTool)):
		return null
	return tools[selectedTool]

func raycast(camera: Camera3D) -> Dictionary:
	var space_state := camera.get_world_3d().direct_space_state
	var mousepos := editor_ui.get_global_mouse_position()

	var origin := camera.project_ray_origin(mousepos)
	var end := origin + camera.project_ray_normal(mousepos) * 1000.0
	var query := PhysicsRayQueryParameters3D.create(origin, end)

	return space_state.intersect_ray(query)

func raycast_plane(camera: Camera3D, plane: Plane) -> Variant:
	var mousepos := editor_ui.get_global_mouse_position()
	return plane.intersects_ray(camera.project_ray_origin(mousepos), camera.project_ray_normal(mousepos) * 1000.0)


var latestRaycast
func processUI(_delta:float):
	var theTool:=getCurrentTool()
	#var shouldUnlockByTool:bool = false
	if(isMenuOpened()):
		return
	if(theTool != null && theTool.shouldUnlockMouse()):
		#shouldUnlockByTool = true
		return
	
	var mousePos:Vector2 = editor_ui.get_global_mouse_position()
	var camera:Camera3D = get_viewport().get_camera_3d()
	
	var rayFrom:Vector3 = camera.project_ray_origin(mousePos)
	var rayTo:Vector3 = rayFrom + camera.project_ray_normal(mousePos) * 1000.0
	
	# Collision mask can be specified here
	var rayParam:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(rayFrom, rayTo)
	rayParam.collision_mask = 0b11111111
	
	var raycastResult:Variant = camera.get_world_3d().get_direct_space_state().intersect_ray(rayParam)
	latestRaycast = raycastResult
	if(!raycastResult):
		return
	
	#var rayCastPosition:Vector3 = raycastResult["position"]
	#var rayCastNormal:Vector3 = raycastResult["normal"]
	#var rayCastCollider = raycastResult["collider"]
	
	#print(rayCastCollider)
#@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var cursor_target: Node3D = $CursorTarget
var previewNode:Node3D

func setPreviewNode(newNode:Node3D, assignMat:bool = true):
	if(previewNode == newNode):
		return
	if(newNode == null):
		if(previewNode == null):
			return
		if(previewNode != null && is_instance_valid(previewNode)):
			previewNode.queue_free()
		previewNode = null
		return
	if(previewNode != null && is_instance_valid(previewNode)):
		previewNode.queue_free()
	cursor_target.add_child(newNode)
	previewNode = newNode
	makeNodePreviewInstant(newNode)
	if(assignMat):
		await get_tree().process_frame
		await get_tree().process_frame
		if(newNode != null && is_instance_valid(newNode)):
			makeNodePreview(newNode)
	
func getPreviewNode() -> Node3D:
	return previewNode

func makeNodePreviewInstant(theNode:Node):
	if(theNode is CollisionShape3D):
		theNode.disabled = true
	if(theNode is Light3D):
		theNode.visible = false
	if(theNode is RigidBody3D || theNode is StaticBody3D || theNode is CharacterBody3D):
		theNode.collision_layer = 0
		theNode.collision_mask = 0
	for childNode in theNode.get_children():
		makeNodePreviewInstant(childNode)

func makeNodePreview(theNode:Node):
	if(theNode is MeshInstance3D):
		for _i in range(theNode.get_surface_override_material_count()):
			theNode.set_surface_override_material(_i, load("res://Mesh/Materials/PreviewMat.tres"))
	for childNode in theNode.get_children():
		makeNodePreview(childNode)

func clearPreviewNode():
	setPreviewNode(null)

func processPreview():
	cursor_target.visible = true
	cursor_target.global_position = getRaycastPosition()
	cursor_target.global_rotation_degrees = getRaycastAngleDeg()
	cursor_target.scale = getRaycastScale()

func isRaycastGood() -> bool:
	return latestRaycast != null && !latestRaycast.is_empty()

func getRaycastPositionRaw() -> Vector3:
	var theResult:Vector3
	
	if(latestRaycast == null || latestRaycast.is_empty()):
		var mousePos:Vector2 = editor_ui.get_global_mouse_position()
		var camera:Camera3D = get_viewport().get_camera_3d()
		var origin := camera.project_ray_origin(mousePos)
		var end := origin + camera.project_ray_normal(mousePos) * 5.0
		theResult = end
	else:
		theResult = latestRaycast["position"]
		
	return theResult

func getRaycastNormalRaw() -> Vector3:
	var theResult:Vector3
	
	if(latestRaycast == null || latestRaycast.is_empty()):
		return Vector3.UP
	else:
		theResult = latestRaycast["normal"]
		
	return theResult

func getRaycastNormalAngRaw() -> Vector3:
	var theNormal:Vector3 = getRaycastNormalRaw()
	
	# Calculate the angles
	var pitch: float = asin(-theNormal.y)  # Angle around the X-axis
	var yaw: float = atan2(theNormal.x, theNormal.z)  # Angle around the Y-axis
	var roll: float = 0.0  # Roll is typically not defined by a normal vector

	var theResult: Vector3 = Vector3(rad_to_deg(pitch), rad_to_deg(yaw), rad_to_deg(roll))

	return theResult

func getRaycastScale() -> Vector3:
	var theResult:Vector3 = Vector3(1.0, 1.0, 1.0)
	var theTool := getCurrentTool()
	if(theTool != null):
		theResult = theTool.processCursorScale(theResult)
	return theResult

func getRaycastPosition() -> Vector3:
	var theResult:Vector3 = getRaycastPositionRaw()
	var theTool := getCurrentTool()
	if(theTool != null):
		theResult = theTool.processCursorPosition(theResult)
	return theResult

func getRaycastAngleDegRaw() -> Vector3:
	var theResult:Vector3 = global_rotation_degrees

	return theResult

func getRaycastAngleDeg() -> Vector3:
	var theResult:Vector3 = getRaycastAngleDegRaw()
	
	var theTool := getCurrentTool()
	if(theTool != null):
		theResult = theTool.processCursorRotationDeg(theResult)
	
	return theResult

func getRaycastAngleRad() -> Vector3:
	var theResult:Vector3 = getRaycastAngleDeg()
	return Vector3(deg_to_rad(theResult.x), deg_to_rad(theResult.y), deg_to_rad(theResult.z))

func getRaycastNode() -> Node3D:
	if(!isRaycastGood()):
		return null
	var collider:Node = latestRaycast["collider"] if is_instance_valid(latestRaycast["collider"]) else null
	if(collider == null || !is_instance_valid(collider)):
		return null
	while(collider != null && !collider.has_meta("PCEDITOR_ID")):
		collider = collider.get_parent()
	
	if(collider == null):
		return null
	return collider

func getRaycastPropID() -> int:
	if(!isRaycastGood()):
		return -1
	var collider:Node = latestRaycast["collider"] if is_instance_valid(latestRaycast["collider"]) else null
	if(collider == null || !is_instance_valid(collider)):
		return -1
	while(collider != null && !collider.has_meta("PCEDITOR_ID")):
		collider = collider.get_parent()
	
	if(collider == null):
		return -1
	return collider.get_meta("PCEDITOR_ID")

func onApplyTool():
	var theTool = getCurrentTool()
	if(theTool == null):
		return
	theTool.onApply(self)

func onApplyAltTool():
	var theTool = getCurrentTool()
	if(theTool == null):
		return
	theTool.onApplyAlt(self)

func getNodeToAddNodes() -> Node:
	return get_parent()

func addEditorChild(theProp:PCEditorProp, nodeSettings:Dictionary = {}, propTransform:Transform3D = Transform3D.IDENTITY, customID:int = -1, transformIsGlobal:bool=false):
	if(customID < 0):
		customID = generateNewPropID()
	else:
		assert(!propEntries.has(customID), "TRYING TO SPAWN A PROP WITH AN ID THAT ALREADY EXISTS: "+str(customID))
	nodeSettings = nodeSettings.duplicate(true)
	#var newTempNode:Node3D = Node3D.new()
	#getNodeToAddNodes().add_child(newTempNode)
	#newTempNode.add_child(theNode)
	#return newTempNode
	var theNode:Node3D = load(theProp.path).instantiate()
	getNodeToAddNodes().add_child(theNode)
	if(transformIsGlobal):
		theNode.transform = propTransform
	else:
		theNode.transform = propTransform * theNode.transform
	if(theNode.has_method("applyEditorOption")):
		for settingID in nodeSettings:
			theNode.applyEditorOption(settingID, nodeSettings[settingID])
	
	if(!hasStaticBodies(theNode)):
		var theStaticBody:StaticBody3D = StaticBody3D.new()
		theNode.add_child(theStaticBody)
		var meshes = getMeshesOfNode(theNode)
		for meshA in meshes:
			var mesh:MeshInstance3D = meshA
			mesh.create_convex_collision(true, true)
	
	propEntries[customID] = {settings = nodeSettings, prop=theProp, node=theNode, id=customID}
	theNode.set_meta("PCEDITOR_ID", customID)
	
	return customID

func findEntryIDNearPos(prop:PCEditorProp, pos:Vector3) -> int:
	for id in propEntries:
		var entry = propEntries[id]
		if(entry["prop"] != prop):
			continue
		var node:Node3D = entry["node"]
		if(node == null || !is_instance_valid(node)):
			continue
		if(node.position.distance_squared_to(pos) < 0.001):
			return id
	return -1

func getMeshesOfNode(theNode:Node) -> Array:
	var result:Array = []
	if(theNode is MeshInstance3D):
		result.append(theNode)
	for child in theNode.get_children():
		result.append_array(getMeshesOfNode(child))
	return result

func hasStaticBodies(_theNode:Node) -> bool:
	for child in _theNode.get_children():
		if(child is StaticBody3D):
			return true
		if(hasStaticBodies(child)):
			return true
	return false

func getNodeByID(_theID:int) -> Node3D:
	if(propEntries.has(_theID)):
		return propEntries[_theID]["node"]
	return null

func getPropByID(_theID:int) -> PCEditorProp:
	if(propEntries.has(_theID)):
		return propEntries[_theID]["prop"]
	return null

func getIDByNode(_node:Node3D) -> int:
	if(!_node.has_meta("PCEDITOR_ID")):
		return -1
	return _node.get_meta("PCEDITOR_ID")

func getPropSettingsByID(_theID:int) -> Dictionary:
	if(propEntries.has(_theID)):
		return propEntries[_theID]["settings"]
	return {}

func getPropSettingsFullByID(_theID:int) -> Dictionary:
	var result:Dictionary = {}
	var theNode:Node = getNodeByID(_theID)
	if(theNode.has_method("getEditorOptions")):
		result = theNode.getEditorOptions()
	var propSettingsApplied:Dictionary = getPropSettingsByID(_theID)
	for settingID in propSettingsApplied:
		if(result.has(settingID)):
			result[settingID]["value"] = propSettingsApplied[settingID]
	return result

func applySettingsFullToProp(_theID:int, newSettings:Dictionary):
	if(!propEntries.has(_theID)):
		return
	var theNode:Node = getNodeByID(_theID)
	if(!theNode.has_method("applyEditorOption")):
		return
	var canApplySettings:Dictionary = {}
	if(theNode.has_method("getEditorOptions")):
		canApplySettings = theNode.getEditorOptions()
	var theSettings:Dictionary = propEntries[_theID]["settings"]
	
	for settingID in newSettings:
		if(!canApplySettings.has(settingID)):
			continue
		if(canApplySettings[settingID]["type"] != newSettings[settingID]["type"]):
			continue
		theSettings[settingID] = newSettings[settingID]["value"]
		theNode.applyEditorOption(settingID, newSettings[settingID]["value"])

func applySettingsToProp(_theID:int, newSettings:Dictionary):
	if(!propEntries.has(_theID)):
		return
	var theNode:Node = getNodeByID(_theID)
	if(theNode.has_method("applyEditorOption")):
		var theSettings:Dictionary = propEntries[_theID]["settings"]
		for settingID in newSettings:
			if(!theSettings.has(settingID)):
				continue
			#if(theSettings["type"] != newSettings["type"]):
			#	continue
			theSettings[settingID] = newSettings[settingID]
			theNode.applyEditorOption(settingID, newSettings[settingID])


func addEditorChildToMousePos(theProp:PCEditorProp, nodeSettings:Dictionary = {}):
	var extraTransform:Transform3D = Transform3D.IDENTITY
	extraTransform.origin = getRaycastPosition()
	extraTransform.basis = Basis.from_euler(getRaycastAngleRad()).scaled(getRaycastScale())
	
	var tempID:int = addEditorChild(theProp, nodeSettings, extraTransform)
	
	return tempID

func addEditorChildToMousePosSymmetry(theProp:PCEditorProp, nodeSettings:Dictionary = {}, axisStr:String = "x", symmetryPoint:Vector3=Vector3(0.0, 0.0, 0.0)):
	var extraTransform:Transform3D = Transform3D.IDENTITY
	extraTransform.origin = getRaycastPosition()
	extraTransform.basis = Basis.from_euler(getRaycastAngleRad()).scaled(getRaycastScale())
	
	extraTransform.origin = symmetrize_position(extraTransform.origin, axisStr, symmetryPoint)
	extraTransform.basis = mirror_basis_across_axis(extraTransform.basis, axisStr)
	var tempID:int = addEditorChild(theProp, nodeSettings, extraTransform)
	
	return tempID

func symmetrize_position(thepos: Vector3, axis: String, symmetry_point: Vector3 = Vector3(0, 0, 0)) -> Vector3:
	# Ensure the provided axis is valid
	if axis not in ["x", "y", "z"]:
		push_error("Invalid axis. Use 'x', 'y', or 'z'.")
		return thepos

	var symmetrized_position = thepos

	# Symmetrize the position across the specified axis and symmetry point
	match axis:
		"x":
			symmetrized_position.x = 2 * symmetry_point.x - thepos.x
		"y":
			symmetrized_position.y = 2 * symmetry_point.y - thepos.y
		"z":
			symmetrized_position.z = 2 * symmetry_point.z - thepos.z

	return symmetrized_position

func mirror_basis_across_axis(abasis: Basis, axisStr: String) -> Basis:
	if(true):
		match axisStr:
			"x":
				var thescale: Vector3 = abasis.get_scale()
				var euler_angles: Vector3 = abasis.get_euler()
				euler_angles.y *= -1.0
				euler_angles.z *= -1.0
				abasis = Basis().rotated(Vector3(0, 1, 0), euler_angles.y) * Basis().rotated(Vector3(1, 0, 0), euler_angles.x) * Basis().rotated(Vector3(0, 0, 1), euler_angles.z)
				abasis = abasis.scaled(thescale)
				return abasis
			"y":
				var thescale: Vector3 = abasis.get_scale()
				var euler_angles: Vector3 = abasis.get_euler()
				euler_angles.x *= -1.0
				euler_angles.z *= -1.0
				euler_angles.z += PI
				abasis = Basis().rotated(Vector3(0, 1, 0), euler_angles.y) * Basis().rotated(Vector3(1, 0, 0), euler_angles.x) * Basis().rotated(Vector3(0, 0, 1), euler_angles.z)
				abasis = abasis.scaled(thescale)
				return abasis
			"z":
				var thescale: Vector3 = abasis.get_scale()
				var euler_angles: Vector3 = abasis.get_euler()
				euler_angles.y += PI
				euler_angles.y *= -1.0
				euler_angles.z *= -1.0
				abasis = Basis().rotated(Vector3(0, 1, 0), euler_angles.y) * Basis().rotated(Vector3(1, 0, 0), euler_angles.x) * Basis().rotated(Vector3(0, 0, 1), euler_angles.z)
				abasis = abasis.scaled(thescale)
				return abasis
	
	var axis:Vector3 = Vector3(1.0, 0.0, 0.0)
	match axisStr:
		"x":
			axis = Vector3(1.0, 0.0, 0.0)
		"y":
			axis = Vector3(0.0, 1.0, 0.0)
		"z":
			axis = Vector3(0.0, 0.0, 1.0)
	# Normalize the axis to ensure it's a unit vector.
	var normalized_axis = axis.normalized()

	#var reflection_quat:Quaternion = Quaternion(normalized_axis, PI)
	
	#var reflection_matrix:Basis = Basis(reflection_quat) * abasis
	

	# Create a reflection matrix for the axis.
	var reflection_matrix = Basis(
		Vector3(1 - 2 * normalized_axis.x * normalized_axis.x, -2 * normalized_axis.x * normalized_axis.y, -2 * normalized_axis.x * normalized_axis.z),
		Vector3(-2 * normalized_axis.y * normalized_axis.x, 1 - 2 * normalized_axis.y * normalized_axis.y, -2 * normalized_axis.y * normalized_axis.z),
		Vector3(-2 * normalized_axis.z * normalized_axis.x, -2 * normalized_axis.z * normalized_axis.y, 1 - 2 * normalized_axis.z * normalized_axis.z)
	)
	#var reflection_matrix = Basis(
		#Vector3(1 - 2 * normalized_axis.x * normalized_axis.x, -2 * normalized_axis.x * normalized_axis.y, -2 * normalized_axis.x * normalized_axis.z),
		#Vector3(-2 * normalized_axis.y * normalized_axis.x, 1 - 2 * normalized_axis.y * normalized_axis.y, -2 * normalized_axis.y * normalized_axis.z),
		#Vector3(-2 * normalized_axis.z * normalized_axis.x, -2 * normalized_axis.z * normalized_axis.y, 1 - 2 * normalized_axis.z * normalized_axis.z)
	#)
	#reflection_matrix = Basis().scaled(Vector3(-1, -1, -1)) * reflection_matrix
	#var reflection_matrix:Basis = Basis()#.scaled(Vector3(-1, -1, -1))  # Start with a negative scale
	#reflection_matrix.x = Vector3(normalized_axis.x * 2 * normalized_axis.x - 1, normalized_axis.x * 2 * normalized_axis.y, normalized_axis.x * 2 * normalized_axis.z)
	#reflection_matrix.y = Vector3(normalized_axis.y * 2 * normalized_axis.x, normalized_axis.y * 2 * normalized_axis.y - 1, normalized_axis.y * 2 * normalized_axis.z)
	#reflection_matrix.z = Vector3(normalized_axis.z * 2 * normalized_axis.x, normalized_axis.z * 2 * normalized_axis.y, normalized_axis.z * 2 * normalized_axis.z - 1)


	# Multiply the basis by the reflection matrix to mirror it.
	#return reflection_matrix * basis
	var mirrored_basis:Basis = reflection_matrix * basis
	#print(mirrored_basis.get_scale())
	
	#mirrored_basis = mirrored_basis.orthonormalized()
	#mirrored_basis = mirrored_basis.scaled(Vector3(-1.0, -1.0, -1.0))
	
	print(mirrored_basis.get_scale())
	return mirrored_basis


func removeEditorChild(theID:int):
	if(propEntries.has(theID)):
		var _theNode:Node3D = getNodeByID(theID)
		if(_theNode != null):
			getNodeToAddNodes().remove_child(_theNode)
		else:
			printerr("NODE NOT FOUND WHILE DETELETING A PROP")
		
		propEntries.erase(theID)
	else:
		printerr("TRYING TO ERASE A PROP THAT WASN'T ADDED TO propEntries")

func gatherChildInfo(_theID:int):
	if(!propEntries.has(_theID)):
		return null
	var propInfo:Dictionary = propEntries[_theID]
	return {
		id = _theID,
		settings = propInfo["settings"],
		prop = propInfo["prop"],
		transform = propInfo["node"].transform,
	}

func addChildFromChildInfo(_theInfo):
	if(_theInfo == null):
		printerr("NULL CHILD INFO PROVIDED, CAN'T SPAWN A PROP")
		return
	
	addEditorChild(_theInfo["prop"], _theInfo["settings"], _theInfo["transform"], _theInfo["id"], true)

# https://www.reddit.com/r/godot/comments/18bfn0n/how_to_calculate_node3d_bounding_box/
static func calculateSpatialBounds(parent : Node, exclude_top_level_transform: bool) -> AABB:
	var bounds : AABB = AABB()
	#if parent is VisualInstance3D:
	if parent is GeometryInstance3D:
		bounds = parent.get_aabb();

	for i in range(parent.get_child_count()):
		var child : Node = parent.get_child(i)
		if child && child is Node3D:
			var child_bounds : AABB = calculateSpatialBounds(child, false)
			if bounds.size == Vector3.ZERO && parent:
				bounds = child_bounds
			else:
				bounds = bounds.merge(child_bounds)
	if bounds.size == Vector3.ZERO && !parent:
		bounds = AABB(Vector3(-0.2, -0.2, -0.2), Vector3(0.4, 0.4, 0.4))
	if !exclude_top_level_transform:
		bounds = parent.transform * bounds
	return bounds

func onCategoryButtonPressed(_category:String):
	currentCategory = _category
	updateProps()

func updateSelectedCategory():
	for buttonA in categoryButtons:
		var button:Button = buttonA
		var theCat:String = button.get_meta("category", "")
		if(theCat == currentCategory):
			button.text = "["+theCat+"]"
		else:
			button.text = theCat

var categoryButtons:Array = []
func updateProps():
	delete_children(category_buttons_list)
	categoryButtons.clear()
	
	for category in assetStash.categories:
		var newButton:Button = Button.new()
		newButton.set_meta("category", category)
		newButton.text = category
		newButton.pressed.connect(onCategoryButtonPressed.bind(category))
		category_buttons_list.add_child(newButton)
		categoryButtons.append(newButton)
	updateSelectedCategory()
	
	prop_item_list.clear()
	if(!assetStash.categories.has(currentCategory)):
		return
	var category:PCEditorPropCategory = assetStash.categories[currentCategory]
	var _i:int = 0
	for path in category.pathToProp:
		var prop:PCEditorProp = category.pathToProp[path]
		var previewTexture:Texture2D = null
		if(assetStash.pathToPreview.has(path)):
			previewTexture = assetStash.pathToPreview[path]
		prop_item_list.add_item(prop.name, previewTexture)
		if(prop == selectedProp):
			prop_item_list.select(_i)
		_i += 1
		
	
func _on_pc_editor_asset_stash_icons_updated() -> void:
	updateProps()

static func delete_children(node: Node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()


func _on_prop_item_list_item_selected(index: int) -> void:
	setNewSelectedProp(assetStash.categories[currentCategory].pathToProp.values()[index])
	
func setNewSelectedProp(newProp:PCEditorProp, customSettingValues:Dictionary = {}):
	selectedProp = newProp
	var theTool = getCurrentTool()
	if(theTool == null):
		return
	theTool.onSelectedPropChanged(self)
	
	var theNodeForSettings:Node = load(selectedProp.path).instantiate()
	if(theNodeForSettings != null):
		selectedPropSettings.clear()
		var settingsID:String = ""
		if(theNodeForSettings.has_method("getEditorOptionsID")):
			settingsID = theNodeForSettings.getEditorOptionsID()
		#savedSettingsByID
		
		if(settingsID == ""):
			settingsID = selectedProp.path
			
		if(!savedSettingsByID.has(settingsID)):
			savedSettingsByID[settingsID] = {}
		selectedPropSettingsValues = savedSettingsByID[settingsID]
		
		if(theNodeForSettings.has_method("getEditorOptions")):
			selectedPropSettings = theNodeForSettings.getEditorOptions()
			
			for settingID in selectedPropSettings:
				if(!selectedPropSettingsValues.has(settingID)):
					selectedPropSettingsValues[settingID] = selectedPropSettings[settingID]["value"]
					
			for settingID in customSettingValues:
				if(selectedPropSettingsValues.has(settingID)):
					selectedPropSettingsValues[settingID] = customSettingValues[settingID]
		updateSelectedPropSettings()
		theNodeForSettings.queue_free()

func getCurrentProp() -> PCEditorProp:
	return selectedProp


func _on_tool_var_list_on_var_change(id: Variant, value: Variant) -> void:
	var theCurrentTool := getCurrentTool()
	if(theCurrentTool == null):
		return
	
	if(theCurrentTool.applySetting(id, value)):
		toolVarList.setVars(theCurrentTool.getSettings())


func _on_prop_var_list_on_var_change(id: Variant, value: Variant) -> void:
	selectedPropSettingsValues[id] = value

func clearMap():
	for node in propEntries.keys():
		removeEditorChild(node)
	propEntries.clear()

func newMap():
	clearMap()
	redoStack.clear()
	undoStack.clear()
	resetGlobalIllumination()

func saveMap() -> PCEditorScene:
	var saveData:Dictionary = {}
	var propsData:Array = []
	for uniqueID in propEntries:
		var propInfo:Dictionary = propEntries[uniqueID]
		var node:Node3D = propInfo["node"]
		
		propsData.append({
			id = uniqueID,
			path = propInfo["prop"].path,
			transform = node.transform,
			settings = propInfo["settings"],
		})
	saveData["props"] = propsData
	
	saveData["pcPos"] = position
	
	var res:PCEditorScene = PCEditorScene.new()
	res.data = saveData
	return res

func loadMap(theMap:PCEditorScene):
	var mapData:Dictionary = theMap.data
	if(mapData.has("pcPos")):
		position = mapData["pcPos"]
	
	if(mapData.has("props")):
		var theProps:Array = mapData["props"]
		
		for propInfo in theProps:
			var propPath:String = propInfo["path"]
			
			if(!assetStash.pathToProp.has(propPath)):
				printerr("PROP IS NOT FOUND: "+propPath)
				continue
			var theTransform:Transform3D = propInfo["transform"]
			var theSettings:Dictionary = propInfo["settings"]
			var theProp:PCEditorProp = assetStash.pathToProp[propPath]
			var theID:int = propInfo["id"] if propInfo.has("id") else generateNewPropID()
			
			addEditorChild(theProp, theSettings, theTransform, theID)


func _on_file_id_pressed(id: int) -> void:
	if(id == 0):
		#newMap()
		doCommand("ClearMap")
		currentMapPath = ""
	if(id == 1):
		if(currentMapPath == ""):
			id = 4
		else:
			_on_save_file_dialog_file_selected(currentMapPath)
	if(id == 4):
		var thePath:String = currentMapPath
		if(thePath == ""):
			thePath = "user://PCEditor/Maps/newmap.res"
		#save_file_dialog.root_subfolder = ProjectSettings.globalize_path("user://PCEditor/Maps/")
		save_file_dialog.current_dir = ProjectSettings.globalize_path(thePath.get_base_dir())#"user://PCEditor/Maps/")
		save_file_dialog.current_file = ProjectSettings.globalize_path(thePath)#"user://PCEditor/Maps/newmap.res")
		save_file_dialog.current_path = ProjectSettings.globalize_path(thePath)
		save_file_dialog.popup_centered()
		#var res:= saveMap()
		#DirAccess.make_dir_absolute(dirBase.path_join("Maps/"))
		#ResourceSaver.save(res, dirBase.path_join("Maps/testMap.res"))
	if(id == 2):
		var thePath:String = currentMapPath
		if(thePath == ""):
			thePath = "user://PCEditor/Maps/newmap.res"
		#open_file_dialog.root_subfolder = ProjectSettings.globalize_path("user://PCEditor/Maps/")
		open_file_dialog.current_dir = ProjectSettings.globalize_path(thePath.get_base_dir())
		open_file_dialog.current_file = ProjectSettings.globalize_path(thePath)
		open_file_dialog.current_path = ProjectSettings.globalize_path(thePath)
		open_file_dialog.popup_centered()
		#var mapPath:String = dirBase.path_join("Maps/testMap.res")
		#if(!ResourceLoader.exists(mapPath)):
			#printerr("MAP NOT FOUND: "+mapPath)
			#return
		#var theMap:PCEditorScene = ResourceLoader.load(mapPath)
		#
		#newMap()
		#loadMap(theMap)
	if(id == 5):
		#open_template_dialog.popup_centered()
		my_template_dialog.popup_centered()

func generateNewPropID() -> int:
	while(propEntries.has(lastUniqueID)):
		lastUniqueID += 1
	return lastUniqueID


func _on_view_id_pressed(id: int) -> void:
	if(id == 0):
		assetStash.regenerateIcons()
	if(id == 1):
		toggleFlashlight()
	if(id == 2):
		if(get_viewport().debug_draw == Viewport.DEBUG_DRAW_WIREFRAME):
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED
		else:
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	if(id == 3):
		if(get_viewport().debug_draw == Viewport.DEBUG_DRAW_OVERDRAW):
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED
		else:
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_OVERDRAW
	if(id == 4):
		resetGlobalIllumination()
	if(id == 5):
		toggleGlobalIllumination()

func resetGlobalIllumination():
	var wenv:=getWorldEnv()
	if(wenv == null):
		return
	var env:=wenv.environment
	if(env == null):
		return
	if(!env.sdfgi_enabled):
		return
	env.sdfgi_enabled = false
	await get_tree().process_frame
	await get_tree().process_frame
	env.sdfgi_enabled = true

func toggleGlobalIllumination():
	var wenv:=getWorldEnv()
	if(wenv == null):
		return
	var env:=wenv.environment
	if(env == null):
		return
	if(env.sdfgi_enabled):
		env.sdfgi_enabled = false
		showMessage("GI is now turned off")
	else:
		env.sdfgi_enabled = true
		showMessage("GI is now turned on")

func toggleFlashlight():
	#get_viewport().debug_draw = Viewport.DEBUG_DRAW_UNSHADED
	flashlight_light.visible = !flashlight_light.visible
	omni_flashlight.visible = !omni_flashlight.visible

func showMessage(theText:String, timeShow:float=3.0):
	messagesList.append({
		text = theText,
		time = timeShow,
	})
func processMessagesList(_delta:float):
	var listSize:int = messagesList.size()
	for _i in range(listSize):
		messagesList[listSize-1-_i]["time"] -= _delta
		if(messagesList[listSize-1-_i]["time"] <= 0.0):
			messagesList.remove_at(listSize-1-_i)
	var newText:String = ""
	for messageStuff in messagesList:
		if(newText != ""):
			newText += "\n"
		newText += messageStuff["text"]
	messages_rich_text.text = newText

func _on_save_file_dialog_file_selected(path: String) -> void:
	showMessage("Saved: "+path.get_file())
	var res:= saveMap()
	ResourceSaver.save(res, path)
	currentMapPath = path


func _on_open_file_dialog_file_selected(mapPath: String, isTemplate:bool = false) -> void:
	showMessage("Loaded: "+mapPath.get_file())
	#var mapPath:String = dirBase.path_join("Maps/testMap.res")
	if(!ResourceLoader.exists(mapPath) && !isTemplate):
		printerr("MAP NOT FOUND: "+mapPath)
		return
	var theMap:PCEditorScene = ResourceLoader.load(mapPath) if !isTemplate else load(mapPath)
	
	newMap()
	loadMap(theMap)
	if(!isTemplate):
		currentMapPath = mapPath
	else:
		currentMapPath = ""

func _on_open_template_dialog_file_selected(path: String) -> void:
	_on_open_file_dialog_file_selected(path, true)


var buildingPlatform:Node3D
func _on_editor_id_pressed(_id: int) -> void:
	if(_id == 0):
		toggleBuildingPlatform(true)
	if(_id == 1):
		position = Vector3()
	if(_id == 2):
		var _ok = OS.shell_open(ProjectSettings.globalize_path(dirBase.path_join("Maps/")))

func toggleBuildingPlatform(showMessages:bool=false):
	if(buildingPlatform != null):
		buildingPlatform.queue_free()
		buildingPlatform = null
		if(showMessages):
			showMessage("Platform hidden")
		return
	buildingPlatform = load("res://Mapping/Dev/building_platform_8x8_gray.tscn").instantiate()
	get_parent().add_child(buildingPlatform)
	if(showMessages):
		showMessage("Platform shown")

func selectPropNextA(howMuchNext:int):
	var category:PCEditorPropCategory = assetStash.categories[currentCategory]
	var _i:int = 0
	for path in category.pathToProp:
		var prop:PCEditorProp = category.pathToProp[path]
		if(prop == selectedProp):
			prop_item_list.select(_i)
			break
		_i += 1
	
	_i += howMuchNext
	if(_i < 0):
		_i = category.pathToProp.size() - 1
	if(_i >= category.pathToProp.size()):
		_i = 0
	_on_prop_item_list_item_selected(_i)
	prop_item_list.select(_i)

func selectNextProp():
	selectPropNextA(1)

func selectPrevProp():
	selectPropNextA(-1)

func getSelectedPropSettingsValues() -> Dictionary:
	var result:Dictionary = selectedPropSettingsValues.duplicate(true)
	
	for settingID in selectedPropSettings:
		if(!selectedPropSettingsValues.has(settingID)):
			result[settingID] = selectedPropSettings[settingID]["value"]
	
	return result
func getFinalSelectedPropSettings() -> Dictionary:
	var result:Dictionary = {}
	
	for settingID in selectedPropSettings:
		result[settingID] = selectedPropSettings[settingID].duplicate(true)
		if(selectedPropSettingsValues.has(settingID)):
			result[settingID]["value"] = selectedPropSettingsValues[settingID]
	
	return result


func _on_reset_prop_settings_button_pressed() -> void:
	selectedPropSettingsValues.clear()
	updateSelectedPropSettings()

func updateSelectedPropSettings():
	prop_var_list.setVars(getFinalSelectedPropSettings())
	if(selectedPropSettings.is_empty()):
		reset_prop_settings_button.visible = false
	else:
		reset_prop_settings_button.visible = true

func getWorldEnv() -> WorldEnvironment:
	var env := findWorldEnv(get_tree().current_scene)
	return env

func findWorldEnv(node:Node, maxDepth:int = 3) -> WorldEnvironment:
	if(node is WorldEnvironment):
		return node
	if(maxDepth <= 0):
		return null
	for childNode in node.get_children():
		var theEnv := findWorldEnv(childNode, maxDepth - 1)
		if(theEnv != null):
			return theEnv
	return null


func _on_my_template_dialog_confirmed() -> void:
	if(template_item_list.get_selected_items().size() < 1):
		return
	_on_open_file_dialog_file_selected(foundTemplates[template_item_list.get_selected_items()[0]], true)
