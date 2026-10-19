extends Node

var profile:PlayerProfile = PlayerProfile.new()

func _ready() -> void:
	profile.loadMainProfile()

func save():
	profile.saveAsMainProfile()
