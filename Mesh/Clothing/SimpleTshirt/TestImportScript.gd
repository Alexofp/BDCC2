@tool # Needed so it runs in editor.
extends EditorScenePostImport

# This sample changes all node names.
# Called right after the scene is imported and gets the root node.
func _post_import(scene):
	# Change all node names to "modified_[oldnodename]"
	iterate(scene)
	return scene # Remember to return the imported scene

# Recursive function that is called on every node
# (for demonstration purposes; EditorScenePostImport only requires a `_post_import(scene)` function).
func iterate(node):
	if node != null:
		for child in node.get_children():
			iterate(child)

		if(node is Skeleton3D):
			var newNode = Node3D.new()
			newNode.name = node.name
			node.replace_by(newNode)
		if(node is AnimationPlayer):
			node.queue_free()
