@tool
extends EditorPlugin

const AiWanderAreaGizmoPlugin = preload("res://addons/bdcc2gizmos/Gizmos/AIWanderAreaGizmo.gd")
const AiLeanLineGizmoPlugin = preload("res://addons/bdcc2gizmos/Gizmos/AILeanLineGizmo.gd")

var aiWanderAreaGizmo := AiWanderAreaGizmoPlugin.new()
var aiLeanLineGizmo := AiLeanLineGizmoPlugin.new()

func _enable_plugin() -> void:
	pass

func _disable_plugin() -> void:
	pass

func _enter_tree():
	add_node_3d_gizmo_plugin(aiWanderAreaGizmo)
	add_node_3d_gizmo_plugin(aiLeanLineGizmo)

func _exit_tree():
	remove_node_3d_gizmo_plugin(aiWanderAreaGizmo)
	remove_node_3d_gizmo_plugin(aiLeanLineGizmo)
