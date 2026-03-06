extends Node3D

@onready var big_sparkles: GPUParticles3D = %BigSparkles

func _ready() -> void:
	big_sparkles.emitting = true

func _on_big_sparkles_finished() -> void:
	queue_free()
