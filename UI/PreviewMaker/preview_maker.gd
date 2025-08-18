extends Control

var preview_viewport: SubViewport
var preview_camera: Camera3D
var previewNode:Node
const preview_size:Vector2i = Vector2i(256, 256)

var dollpartPathToTextureVariants:Dictionary[String, Array] = {}

@onready var preview_item_list: ItemList = %PreviewItemList

func _ready() -> void:
	setup_preview_viewport()
	
	calcDollpathDict()
	preview_item_list.clear()
	for thePath in dollpartPathToTextureVariants:
		preview_item_list.add_item(thePath.get_file())

func calcDollpathDict():
	dollpartPathToTextureVariants.clear()
	
	for textureVariantID in GlobalRegistry.textureVariants:
		var theTextureVatiant:TextureVariant = GlobalRegistry.getTextureVariant(textureVariantID)
		if(theTextureVatiant.previewDollPartPath == ""):
			continue
		if(!dollpartPathToTextureVariants.has(theTextureVatiant.previewDollPartPath)):
			dollpartPathToTextureVariants[theTextureVatiant.previewDollPartPath] = []
		dollpartPathToTextureVariants[theTextureVatiant.previewDollPartPath].append(theTextureVatiant)

func _on_do_previews_button_pressed() -> void:
	var allThePaths:Array = dollpartPathToTextureVariants.keys()
	var selectedIDs:Array = preview_item_list.get_selected_items()
	for theID in selectedIDs:
		var thePath:String = allThePaths[theID]
		preparePreview(load(thePath).instantiate())
		for textureVarA in dollpartPathToTextureVariants[thePath]:
			var textureVar:TextureVariant = textureVarA
			var theTexture := await generatePreviewTextureVariant(textureVar)
			theTexture.get_image().save_png(getSavePreviewFolder().path_join(textureVar.id+".png"))
		stopPreview()
	
	#var theBody = load("res://Mesh/Parts/Body/FeminineBody/feminine_body.tscn").instantiate()
	#var theTexture := await generatePreview(theBody)
	#theTexture.get_image().save_png("user://testPreview.png")

func getSavePreviewFolder() -> String:
	if(OS.has_feature("editor")):
		return TextureVariantMany.PreviewFolder
	return "user://Game/TextureVariantPreviews/"

func setup_preview_viewport() -> void:
	preview_viewport = SubViewport.new()
	preview_viewport.size = preview_size
	preview_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	preview_viewport.transparent_bg = false
	preview_viewport.scaling_3d_mode = SubViewport.SCALING_3D_MODE_BILINEAR
	preview_viewport.own_world_3d = true
	preview_viewport.world_3d = World3D.new()
	preview_viewport.world_3d.environment = Environment.new()
	preview_viewport.world_3d.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	preview_viewport.world_3d.environment.ambient_light_color = Color(1.0, 1.0, 1.0, 1.0)
	preview_viewport.world_3d.environment.ambient_light_energy = 0.2

	preview_camera = Camera3D.new()
	preview_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	
	var someDirLight := DirectionalLight3D.new()
	someDirLight.rotation_degrees = Vector3(-45, -45, 0)
	someDirLight.light_energy = 2.0
	preview_viewport.add_child(someDirLight)

	preview_viewport.add_child(preview_camera)
	add_child(preview_viewport)

func preparePreview(node: Node):
	if(previewNode):
		assert(false, "Already previewing something!")
		return
	previewNode = node
	preview_viewport.add_child(node)
	
	var aabb := get_aabb(node)

	if is_zero_approx(aabb.size.length()):
		return

	var max_size := max(aabb.size.x, aabb.size.y, aabb.size.z) as float

	preview_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	preview_camera.size = max_size# * 1.1
	preview_camera.look_at_from_position(Vector3(max_size, max_size, max_size), aabb.get_center())
	
	if(node.has_method("prepareForPreview")):
		node.prepareForPreview(self)
	
func generatePreviewTextureVariant(_textureVar:TextureVariant) -> Texture2D:
	if(previewNode.has_method("previewTextureVariant")):
		previewNode.previewTextureVariant(self, _textureVar)
	
	preview_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	var viewport_image := preview_viewport.get_texture().get_image()
	var preview := ImageTexture.create_from_image(viewport_image)
	return preview

func stopPreview():
	if(!previewNode):
		return
	preview_viewport.remove_child(previewNode)
	previewNode.queue_free()
	previewNode = null

func generatePreview(node: Node) -> Texture2D:
	if(previewNode):
		assert(false, "Already previewing something!")
		return
	preview_viewport.add_child(node)
	
	#if(node.has_method("getEditorOptions")):
	#	var editorOptions:Dictionary = node.getEditorOptions()
	#	for optionID in editorOptions:
	#		node.applyEditorOption(optionID, editorOptions[optionID]["value"])
	preview_viewport.size = preview_size

	var aabb := get_aabb(node)

	if is_zero_approx(aabb.size.length()):
		return

	var max_size := max(aabb.size.x, aabb.size.y, aabb.size.z) as float

	preview_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	preview_camera.size = max_size * 1.1
	preview_camera.look_at_from_position(Vector3(max_size, max_size, max_size), aabb.get_center())

	await RenderingServer.frame_post_draw
	var viewport_image := preview_viewport.get_texture().get_image()
	# BDCC2-PATCH STARTS
	#var preview := PortableCompressedTexture2D.new()
	var preview := ImageTexture.create_from_image(viewport_image)
	#preview.create_from_image(viewport_image, PortableCompressedTexture2D.COMPRESSION_MODE_LOSSY)
	#preview.create_from_image(viewport_image, Texture2D.)
	# BDCC2-PATCH ENDS
	
	preview_viewport.remove_child(node)
	node.queue_free()

	return preview

func get_aabb(node: Node) -> AABB:
	var aabb := AABB()

	var children: Array[Node] = []
	children.append(node)

	while not children.is_empty():
		var child := children.pop_back() as Node

		#if child is VisualInstance3D:
		if child is GeometryInstance3D:
			var child_aabb := child.get_aabb().abs() as AABB
			var transformed_aabb := AABB(child_aabb.position + child.global_position, child_aabb.size)
			aabb = aabb.merge(transformed_aabb)
		
		children.append_array(child.get_children())

	return aabb


func _on_open_folder_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path(getSavePreviewFolder()))

func _on_close_button_pressed() -> void:
	GM.startMainMenu()
