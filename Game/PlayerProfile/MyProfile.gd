extends Node

var profile:PlayerProfile = PlayerProfile.new()
var newPlayer:bool = false

func _ready() -> void:
	if(!profile.loadMainProfile()):
		newPlayer = true

func save():
	profile.saveAsMainProfile()

func isNewPlayer():
	return newPlayer
