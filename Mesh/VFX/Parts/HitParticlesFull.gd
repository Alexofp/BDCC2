extends Node3D

@onready var big_hit: GPUParticles3D = %BigHit
@onready var sparkles: GPUParticles3D = %Sparkles
@onready var big_sparkles: GPUParticles3D = %BigSparkles

func _ready() -> void:
	#big_hit.emitting = true
	#sparkles.emitting = true
	big_sparkles.emitting = true

func _on_sparkles_finished() -> void:
	queue_free()

func _on_big_sparkles_finished() -> void:
	queue_free()
