@tool
extends EditorPlugin

var button: Button
var button2: Button

func _enter_tree():
	button = Button.new()
	button.text = "BoxCol"
	button.pressed.connect(_on_button_pressed)
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, button)
	button.visible = false  # Initially hide the button

	button2 = Button.new()
	button2.text = "BoxOcc"
	button2.pressed.connect(_on_button2_pressed)
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, button2)
	button2.visible = false  # Initially hide the button

	# Connect to the selection changed signal
	get_editor_interface().get_selection().selection_changed.connect(_on_selection_changed)

func _exit_tree():
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, button)
	get_editor_interface().get_selection().selection_changed.disconnect(_on_selection_changed)

func _on_selection_changed():
	var selectedAll := get_editor_interface().get_selection().get_selected_nodes()
	if(selectedAll.size() > 0):
		var selected = selectedAll[0]
		button.visible = selected is MeshInstance3D  # Show button if selected node is a MeshInstance3D
		button2.visible = selected is MeshInstance3D  # Show button if selected node is a MeshInstance3D
	else:
		button.visible = false
		button2.visible = false

func _on_button_pressed():
	var selectedAll := get_editor_interface().get_selection().get_selected_nodes()
	if(selectedAll.size() <= 0):
		return
	var selected = selectedAll[0]
	
	if selected is MeshInstance3D:
		var aabb = selected.get_aabb()
		var static_body = StaticBody3D.new()
		static_body.name = "StaticBody3D"
		var box_shape = BoxShape3D.new()
		var Collider = CollisionShape3D.new()
		box_shape.extents = aabb.size / 2  # Set extents to half the size of the AABB
		Collider.shape = box_shape
		Collider.name = "CollisionShape3D"
		#selected.get_parent().add_child(static_body)
		selected.add_child(static_body)
		static_body.add_child(Collider)
		static_body.transform.origin = aabb.position + aabb.size / 2  # Center the StaticBody
		static_body.owner = get_tree().edited_scene_root
		Collider.owner = get_tree().edited_scene_root
		print("Converted to StaticBody3D")
	else:
		print("Select a MeshInstance3D to convert.")
		
func _on_button2_pressed():
	var selectedAll := get_editor_interface().get_selection().get_selected_nodes()
	if(selectedAll.size() <= 0):
		return
	var selected = selectedAll[0]
	
	if selected is MeshInstance3D:
		var aabb:AABB= selected.get_aabb()
		
		var reused:bool = false
		var occluder_instance:OccluderInstance3D
		if(selected.has_node("OccluderInstance3D")):
			occluder_instance = selected.get_node("OccluderInstance3D")
			reused = true
		else:
			occluder_instance = OccluderInstance3D.new()
			occluder_instance.name = "OccluderInstance3D"
		

		if(isAABBCloseToPlane(aabb, 0.3)):
			#print("PLANEEE!")
			createQuadOccluderFromAABB(aabb, occluder_instance)
			#occluder_instance.occluder = plane_occuluder
			#occluder_instance.transform.origin = aabb.position + aabb.size / 2  # Center the OccluderInstance
			if(selected.name.begins_with("Wall")):
				occluder_instance.position.z = 0.0
		else:
			#print("BOOOOX")
			var box_occluder = BoxOccluder3D.new()
			box_occluder.size = aabb.size
			occluder_instance.occluder = box_occluder
			occluder_instance.transform.origin = aabb.position + aabb.size / 2  # Center the OccluderInstance

		#selected.get_parent().add_child(occluder_instance)
		if(!reused):
			selected.add_child(occluder_instance)
			occluder_instance.owner = get_tree().edited_scene_root
			print("Created OccluderInstance3D")
		else:
			print("Reused OccluderInstance3D")
	else:
		print("Select a MeshInstance3D to create an occluder.")



func isAABBCloseToPlane(aabb: AABB, threshold: float = 0.1) -> bool:
	var size = aabb.size
	var width = size.x
	var height = size.y
	var depth = size.z

	# Calculate the maximum dimension
	var max_dimension = max(width, height, depth)

	# Calculate the relative sizes
	var width_ratio = width / max_dimension
	var height_ratio = height / max_dimension
	var depth_ratio = depth / max_dimension
	#print(width_ratio)
	#print(height_ratio)
	#print(depth_ratio)

	if(width_ratio < threshold || height_ratio < threshold || depth_ratio < threshold):
		return true

	# Check if one dimension is significantly smaller than the others
	#if width_ratio < threshold and height_ratio > threshold and depth_ratio > threshold:
		#return true  # Close to a vertical plane
	#elif height_ratio < threshold and width_ratio > threshold and depth_ratio > threshold:
		#return true  # Close to a horizontal plane
	#elif depth_ratio < threshold and width_ratio > threshold and height_ratio > threshold:
		#return true  # Close to a depth plane

	return false  # Not close to a plane

func sort_ascending(a, b):
	if a["value"] > b["value"]:
		return true
	return false

func createQuadOccluderFromAABB(aabb: AABB, occluder_instance: OccluderInstance3D) -> QuadOccluder3D:
	var size = aabb.size
	var dimensions = [
		{"axis": "x", "value": size.x},
		{"axis": "y", "value": size.y},
		{"axis": "z", "value": size.z}
	]
	
	#print(dimensions)
	# Sort dimensions by size, descending
	dimensions.sort_custom(sort_ascending)
	#dimensions.sort_custom(func(a, b): a["value"] > b["value"])
	#print(dimensions)
	
	# Get the two largest dimensions
	var largest = dimensions[0]
	var second_largest = dimensions[1]
	
	# Create the QuadOccluder3D
	var occluder := QuadOccluder3D.new()
	occluder_instance.occluder = occluder
	
	# Set the size of the occluder to the two largest dimensions
	occluder.size = Vector2(largest["value"], second_largest["value"]) + Vector2(0.02, 0.02)
	
	# Position the occluder at the center of the AABB
	var center = aabb.position + aabb.size * 0.5
	occluder_instance.transform.origin = center
	
	# Determine the orientation of the occluder based on the axes of the two largest dimensions
	var rotation = Vector3()
	if largest["axis"] == "x" and second_largest["axis"] == "y":
		rotation = Vector3(0, 0, 0)  # XY plane (facing Z-axis)   # FIXED
	elif largest["axis"] == "x" and second_largest["axis"] == "z":
		rotation = Vector3(90, 0, 0)  # XZ plane (facing Y-axis)  # FIXED
	elif largest["axis"] == "y" and second_largest["axis"] == "x":
		rotation = Vector3(0, 0, 90)  # XY plane (facing Z-axis)   # FIXED
	elif largest["axis"] == "y" and second_largest["axis"] == "z":
		rotation = Vector3(0, 90, 90)  # YZ plane (facing X-axis)   # FIXED
	elif largest["axis"] == "z" and second_largest["axis"] == "x":
		rotation = Vector3(90, 0, 90)  # XZ plane (facing Y-axis)    # FIXED
	elif largest["axis"] == "z" and second_largest["axis"] == "y":
		rotation = Vector3(0, 90, 0)  # YZ plane (facing X-axis)  # FIXED
	
	# Apply rotation
	occluder_instance.rotation_degrees = rotation
	
	return occluder
