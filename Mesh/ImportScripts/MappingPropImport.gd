@tool
extends EditorScenePostImport

func _post_import(scene:Node):
	#var newStatic:StaticBody3D = StaticBody3D.new()
	#scene.add_child(newStatic)
	#newStatic.owner = scene
	#newStatic.owner = get_tree().edited_scene_root
	
	iterate(scene)
	if(scene.name.ends_with("2") && !scene.name.ends_with("x2")):
		scene.name = scene.name.substr(0, scene.name.length()-1)
	
	if(scene.name.begins_with("Wall") || scene.name.begins_with("Window")):
		scene.set_script(preload("res://Mapping/WallBasic.gd"))
		scene.editorOptionsID = "wall"
	elif(scene.name.begins_with("BackWall")):
		scene.set_script(preload("res://Mapping/BackWallBasic.gd"))
		scene.editorOptionsID = "backwall"
	elif(scene.name.begins_with("BigFloor")):
		scene.set_script(preload("res://Mapping/FloorBasic.gd"))
		#scene.editorOptionsID = "backwall"
	elif(scene.name.begins_with("Tile")):
		scene.set_script(preload("res://Mapping/FloorTileBasic.gd"))
		scene.editorOptionsID = "tile"
	elif(scene.name.begins_with("Stairs")):
		scene.set_script(preload("res://Mapping/StairsBasic.gd"))
		scene.editorOptionsID = "stairs"
	elif(scene.name.begins_with("FancyRailing")):
		scene.set_script(preload("res://Mapping/FancyRailingBasic.gd"))
		scene.editorOptionsID = "fancyrailing"
	elif(scene.name.begins_with("Foundation")):
		scene.set_script(preload("res://Mapping/FoundationBasic.gd"))
		scene.editorOptionsID = "foundation"
	elif(scene.name.begins_with("Column")):
		scene.set_script(preload("res://Mapping/ColumnBasic.gd"))
		scene.editorOptionsID = "column"
	elif(scene.name.begins_with("Decal")):
		scene.set_script(preload("res://Mapping/DecalBasic.gd"))
		scene.editorOptionsID = "decal"
	elif(scene.name.begins_with("Pipe")):
		scene.set_script(preload("res://Mapping/PipeBasic.gd"))
		scene.editorOptionsID = "pipe"
	else:
		scene.set_script(preload("res://Mapping/PropBasic.gd"))
		
	return scene

func iterate(node, depth:int=0):
	if !node:
		return
	
	if(node is MeshInstance3D):
		if(depth <= 1):
			node.position = Vector3()
		processMeshInstanceMats(node)
		
		var nodeName:String = node.name
		if("_lod" in nodeName):
			pass
		else:
			var lods:Array = []
			var _i:int = 1
			while(node.get_parent().has_node(nodeName+"_lod"+str(_i))):
				lods.append(node.get_parent().get_node(nodeName+"_lod"+str(_i)))
				_i += 1
			
			if(lods.size() == 0):
				node.visibility_range_end = 250.0
				pass
			elif(lods.size() == 1):
				node.visibility_range_end = 10.0
				lods[0].visibility_range_begin = 10.0
				lods[0].visibility_range_end = 150.0
			elif(lods.size() == 2):
				node.visibility_range_end = 10.0
				lods[0].visibility_range_begin = 10.0
				lods[0].visibility_range_end = 20.0
				lods[1].visibility_range_begin = 20.0
				lods[1].visibility_range_end = 150.0
			else:
				node.visibility_range_end = 10.0
				lods[0].visibility_range_begin = 10.0
				lods[0].visibility_range_end = 20.0
				lods[1].visibility_range_begin = 20.0
				lods[1].visibility_range_end = 30.0
				lods[2].visibility_range_begin = 30.0
				lods[2].visibility_range_end = 150.0
			
		
	if(node is StaticBody3D):
		if(depth <= 1):
			node.position = Vector3()
		
	#node.name = "modified_" + node.name
	for child in node.get_children():
		iterate(child, depth+1)

func processMeshInstanceMats(node:MeshInstance3D):
	if(!node.mesh):
		return
	
	var mesh:=node.mesh
	var surfaceAmount:int = mesh.get_surface_count()
	for _i in range(surfaceAmount):
		var surfaceName:String = mesh.get("surface_"+str(_i)+"/name")
		
		if(surfaceName.begins_with("MyBigTrim")):
			node.set_surface_override_material(_i, load("res://Mesh/Materials/MyBigTrimSmart.tres"))
		if(surfaceName.begins_with("MyTrim")):
			node.set_surface_override_material(_i, load("res://Mesh/Materials/MyTrimSmart.tres"))
		if(surfaceName.begins_with("MyDecals")):
			node.set_surface_override_material(_i, load("res://Mesh/Materials/MyDecalTrimSmart.tres"))
		if(surfaceName.begins_with("Glass")):
			node.set_surface_override_material(_i, load("res://Mesh/Materials/GlassMat.tres"))
		if(surfaceName.begins_with("MyFloorTrim")):
			node.set_surface_override_material(_i, load("res://Mesh/Materials/MyFloorTrimSmart.tres"))
		if(surfaceName.begins_with("ShinyTubeMat")):
			node.set_surface_override_material(_i, load("res://Mesh/Materials/MyPipeMaterial.tres"))
			
