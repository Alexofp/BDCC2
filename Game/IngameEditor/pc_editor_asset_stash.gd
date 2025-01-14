extends Node3D
class_name PCEditorAssetStash

var preview_viewport: SubViewport
var preview_camera: Camera3D
const preview_size:Vector2i = Vector2i(128, 128)

var categories:Dictionary = {}
var pathToPreview:Dictionary = {}
var pathToProp:Dictionary = {}

var previewsToGenerate:Array = []
var isGeneratingPreview:bool = false

const assetsPath = "res://Mapping/"

signal IconsUpdated

var messenger

func _ready() -> void:
	loadIconCache()
	setup_preview_viewport()
	readAssets()

func _process(_delta: float) -> void:
	tryToGenerateNextPreview()

func tryToGenerateNextPreview():
	if(isGeneratingPreview):
		return
	if(previewsToGenerate.is_empty()):
		return
	isGeneratingPreview = true
	var nextPath:String = previewsToGenerate.pop_back()
	
	if(!ResourceLoader.exists(nextPath)):
		showMessage("NOT FOUND, SKIPPING: "+str(nextPath))
		if(pathToPreview.has(nextPath)):
			pathToPreview.erase(nextPath)
	else:
		var theAsset:Node = load(nextPath).instantiate()
		var theTexture:Texture2D = await generatePreview(theAsset)
		pathToPreview[nextPath] = theTexture
		showMessage("GENERATED PREVIEW FOR "+str(nextPath.get_file())+" LEFT: "+str(previewsToGenerate.size()))
	
	isGeneratingPreview = false
	if(previewsToGenerate.size() <= 0):
		saveIconCache()
		IconsUpdated.emit()
		showMessage("DONE GENERATING PREVIEWS", 3)

func saveIconCache():
	var newCache:PCEditorIconCache = PCEditorIconCache.new()
	newCache.data = {
		icons = pathToPreview,
	}
	ResourceSaver.save(newCache, PlayerEditor.dirBase.path_join("iconCache.res"))

func loadIconCache():
	var cachePath:String = PlayerEditor.dirBase.path_join("iconCache.res")
	
	if(ResourceLoader.exists(cachePath)):
		var theCache:PCEditorIconCache = ResourceLoader.load(cachePath)
		if(theCache.data.has("icons")):
			pathToPreview = theCache.data["icons"]
	elif(ResourceLoader.exists("res://Game/IngameEditor/Util/iconCache.res")):
		var theCache:PCEditorIconCache = ResourceLoader.load("res://Game/IngameEditor/Util/iconCache.res")
		if(theCache.data.has("icons")):
			pathToPreview = theCache.data["icons"]

func readAssets():
	var files:Array = getFilesInFolderSmart(assetsPath, "tscn", true, true, true)
	
	for pathA in files:
		var path:String = pathA
		var theSplit:Array = path.split("/")
		if(("Raw" in theSplit) || ("RAW" in theSplit) || ("raw" in theSplit)):
			continue
		
		var theName:String = path.get_file().get_basename()
		var theCategory:String = path.get_base_dir().substr(assetsPath.length())
		if(theCategory == ""):
			theCategory = "Root"
		
		if(!categories.has(theCategory)):
			categories[theCategory] = PCEditorPropCategory.new()
		
		var newProp:PCEditorProp = PCEditorProp.new()
		newProp.path = path
		newProp.name = theName
		
		categories[theCategory].pathToProp[path] = newProp
		pathToProp[path] = newProp
		if(!pathToPreview.has(path)):
			previewsToGenerate.append(path)

static func getFilesInFolderSmart(folder: String, ext: String, includeThisFolder = true, includeSubFolders = true, reqursive = true):
	var result = []
	
	var dir = DirAccess.open(folder)
	if dir:
		dir.include_navigational = false
		dir.list_dir_begin()
		var file_name = PCEditorUtil.fix_resource_path(dir.get_next())
		while file_name != "":
			if dir.current_is_dir():
				if(includeSubFolders):
					var full_path = folder.path_join(file_name)
					result.append_array(getFilesInFolderSmart(full_path, ext, true, reqursive))
				#print("Found directory: " + file_name)
			else:
				if(!includeThisFolder):
					file_name = PCEditorUtil.fix_resource_path(dir.get_next())
					continue
				if(file_name.get_extension() == ext):
					var full_path = folder.path_join(file_name)
					result.append(full_path)
			file_name = PCEditorUtil.fix_resource_path(dir.get_next())
	else:
		printerr("An error occurred when trying to access the path "+folder)
	
	return result

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
	preview_viewport.world_3d.environment.ambient_light_color = Color(2.0, 2.0, 2.0, 1.0)

	preview_camera = Camera3D.new()
	preview_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	
	var someDirLight := DirectionalLight3D.new()
	someDirLight.rotation_degrees = Vector3(-45, -45, 0)
	someDirLight.light_energy = 5.0
	preview_viewport.add_child(someDirLight)

	preview_viewport.add_child(preview_camera)
	add_child(preview_viewport)

func generatePreview(node: Node) -> Texture2D:
	preview_viewport.add_child(node)
	if(node.has_method("getEditorOptions")):
		var editorOptions:Dictionary = node.getEditorOptions()
		for optionID in editorOptions:
			node.applyEditorOption(optionID, editorOptions[optionID]["value"])
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

func regenerateIcons():
	var didAdd:Dictionary = {}
	for path in pathToPreview:
		if(!didAdd.has(path)):
			didAdd[path] = true
			previewsToGenerate.append(path)

func showMessage(_text:String, howLong:int=1):
	if(messenger):
		messenger.showMessage(_text, howLong)
	print(_text)
