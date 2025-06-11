extends AnimationTree

func _enter_tree() -> void:
	ProcessBalancer.addAnimTree(self)

func _exit_tree() -> void:
	ProcessBalancer.removeAnimTree(self)
