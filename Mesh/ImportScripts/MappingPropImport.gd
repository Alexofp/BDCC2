@tool
extends EditorScenePostImport

func _post_import(scene:Node):
	#var newStatic:StaticBody3D = StaticBody3D.new()
	#scene.add_child(newStatic)
	#newStatic.owner = scene
	#newStatic.owner = get_tree().edited_scene_root
	
	var toDelete:Array[Node] = []
	iterate(scene, 0, toDelete)
	#print("TODELETE: ",toDelete)
	for theNode in toDelete:
		theNode.queue_free()
	
	if(scene.name.ends_with("2") && !scene.name.ends_with("x2")):
		scene.name = scene.name.substr(0, scene.name.length()-1)
	
	if(scene.name.begins_with("Wall") || scene.name.begins_with("Window")):
		scene.set_script(preload("res://Mapping/WallBasic.gd"))
	elif(scene.name.begins_with("BackWall")):
		scene.set_script(preload("res://Mapping/BackWallBasic.gd"))
	elif(scene.name.begins_with("BigFloor")):
		scene.set_script(preload("res://Mapping/FloorBasic.gd"))
	elif(scene.name.begins_with("Tile")):
		scene.set_script(preload("res://Mapping/FloorTileBasic.gd"))
	elif(scene.name.begins_with("Stairs")):
		scene.set_script(preload("res://Mapping/StairsBasic.gd"))
	elif(scene.name.begins_with("FancyRailing")):
		scene.set_script(preload("res://Mapping/FancyRailingBasic.gd"))
	elif(scene.name.begins_with("Foundation")):
		scene.set_script(preload("res://Mapping/FoundationBasic.gd"))
	elif(scene.name.begins_with("Column")):
		scene.set_script(preload("res://Mapping/ColumnBasic.gd"))
	elif(scene.name.begins_with("Decal")):
		scene.set_script(preload("res://Mapping/DecalBasic.gd"))
	elif(scene.name.begins_with("Pipe")):
		scene.set_script(preload("res://Mapping/PipeBasic.gd"))
	else:
		scene.set_script(preload("res://Mapping/PropBasic.gd"))
		
	return scene

func iterate(node, depth:int=0, toDelete:Array[Node] = []):
	if !node:
		return
	
	if(node is MeshInstance3D):
		if(depth <= 1):
			node.position = Vector3()
		
		
		var nodeName:String = node.name
		if("_lod" in nodeName):
			pass
		else:
			var lods:Array[MeshInstance3D] = []
			var _i:int = 1
			while(node.get_parent().has_node(nodeName+"_lod"+str(_i))):
				lods.append(node.get_parent().get_node(nodeName+"_lod"+str(_i)))
				_i += 1
			
			if(true):
				#print(lods)
				var theAAB:AABB = node.get_aabb()
				var biggestSize:float = max(theAAB.size.x, max(theAAB.size.y, theAAB.size.z))
				#print(biggestSize)
				if(biggestSize >= 0.98):
					node.visibility_range_end = 200.0
					node.visibility_range_end_margin = 20.0
				else:
					# Small object culling
					var theVisRange:float = clampf(biggestSize*100.0, 50.0, 200.0)
					node.visibility_range_end = theVisRange
					node.visibility_range_end_margin = theVisRange*0.1
				
				combineLodsForMeshInstance3D(node, lods)
				for theLod in lods:
					toDelete.append(theLod)
			else:
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
			
		processMeshInstanceMats(node)
	if(node is StaticBody3D):
		if(depth <= 1):
			node.position = Vector3()
		
	#node.name = "modified_" + node.name
	for child in node.get_children():
		iterate(child, depth+1, toDelete)

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
			
func lodToDistance(_indx:int) -> float:
	return float(_indx + 1) * 0.01

func combineLodsForMeshInstance3D(_meshInstance:MeshInstance3D, _lods:Array[MeshInstance3D]):
	if(_lods.is_empty()):
		return
	var theMainMesh:Mesh = _meshInstance.mesh
	var theMainShadowMesh:ArrayMesh = theMainMesh.shadow_mesh if(theMainMesh is ArrayMesh) else null
	
	var theLods:Array[Mesh]
	var theShadowLods:Array[Mesh]
	
	for theLod in _lods:
		theLods.append(theLod.mesh)
		if((theLod.mesh is ArrayMesh) && theLod.mesh.shadow_mesh):
			theShadowLods.append(theLod.mesh.shadow_mesh)
	
	_meshInstance.mesh = combineLods(_meshInstance.mesh, theLods, _meshInstance.name)
	if(theMainShadowMesh):
		if(theLods.size() == theShadowLods.size()):
			#print("== SHADOW MESH ==")
			_meshInstance.mesh.shadow_mesh = combineLods(theMainShadowMesh, theShadowLods, "(Shadow-mesh)"+_meshInstance.name, true)
			pass
		else:
			printerr("The amount of lods and shadow-mesh lods don't match, skipping shadow mesh generation for ",_meshInstance.name)
	
func combineLods(_mesh:Mesh, _lodMeshes:Array[Mesh], _nameHint:String = "UNKNOWN", _isShadow:bool = false) -> Mesh:
	if(_lodMeshes.is_empty()):
		return _mesh
	
	var theImporterMesh:ImporterMesh = ImporterMesh.from_mesh(_mesh)
	var surfaceAm:int = theImporterMesh.get_surface_count()
	
	var lodImporterMeshes:Array[ImporterMesh]
	for theMesh in _lodMeshes:
		var newLodMesh := ImporterMesh.from_mesh(theMesh)
		lodImporterMeshes.append(newLodMesh)
	
	var resultMesh:ImporterMesh = ImporterMesh.new()
	resultMesh.set_lightmap_size_hint(theImporterMesh.get_lightmap_size_hint())
	resultMesh.set_blend_shape_mode(theImporterMesh.get_blend_shape_mode())
	
	for _surfaceIndx in surfaceAm:
		var theArrays:Array = theImporterMesh.get_surface_arrays(_surfaceIndx)
		var curIndx:int = theArrays[0].size()
		var theLods:Dictionary[float, PackedInt32Array]
		var theFlags := theImporterMesh.get_surface_format(_surfaceIndx)
		
		var _lodIndx:int = 0
		for lodMesh in lodImporterMeshes:
			var theLodDistance := lodToDistance(_lodIndx)
			
			# Missing surface fallback. Just add 1 invisible triangle
			if(_surfaceIndx >= lodMesh.get_surface_count()):
				theLods[theLodDistance] = PackedInt32Array([0, 0, 0])
				_lodIndx += 1
				continue
			
			#if(lodMesh.get_surface_format(_surfaceIndx) != theFlags):
			#	printerr("FLAGS ARE WRONG! LodMesh=",lodMesh.get_surface_format(_surfaceIndx)," MainMesh=",theFlags)
			
			var theLodArrays := lodMesh.get_surface_arrays(_surfaceIndx)
			for _i in Mesh.ARRAY_MAX:
				if(_i >= theArrays.size() || theArrays[_i] == null):
					continue
				if(_i != Mesh.ARRAY_INDEX): # Most data can just be appended to old data
					theArrays[_i].append_array(theLodArrays[_i])
					continue
				# Handling indicies
				var theLodIndicies:PackedInt32Array = theLodArrays[_i]
				var theLodIndAm:int = theLodIndicies.size()
				for _lodI in theLodIndAm:
					theLodIndicies[_lodI] += curIndx
				theLods[theLodDistance] = theLodIndicies
				if(theLodIndAm >= theArrays[_i].size()): # A work-around for when the lod has the same amount of triangles as the main mesh. Will throw an error otherwise
					theArrays[_i].resize(theLodIndAm+3)
				curIndx += theLodArrays[0].size()
				#print("LOD INDX AM: ",theLodIndAm," MAIN MESH INDX AM: ",theArrays[_i].size())
				
			_lodIndx += 1
		
		var theMat:Material = null#theImporterMesh.get_surface_material(_surfaceIndx)
		var theName:String = theImporterMesh.get_surface_name(_surfaceIndx)
		var thePrimType := theImporterMesh.get_surface_primitive_type(_surfaceIndx)
		
		resultMesh.add_surface(thePrimType, theArrays, [], theLods, theMat, theName, theFlags)
		#print("PRIM TYPE: ", thePrimType," VERT AMOUNT: ",theArrays[0].size())

	#for _surfaceIndx in resultMesh.get_surface_count():
		#for _MAINLOD in resultMesh.get_surface_lod_count(_surfaceIndx):
			#print("SURFACE INDX: ",_surfaceIndx," LOD: ",_MAINLOD)
			#print(resultMesh.get_surface_lod_size(_surfaceIndx, _MAINLOD))
			#print(resultMesh.get_surface_lod_indices(_surfaceIndx, _MAINLOD).size())

	return resultMesh.get_mesh()
