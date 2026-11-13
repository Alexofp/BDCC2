extends AnimationTree

func _enter_tree() -> void:
	ProcessBalancer.addAnimTree(self)
