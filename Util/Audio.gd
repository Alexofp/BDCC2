extends Object
class_name Audio

const BUS_SOUNDS = "Sounds"
const BUS_VOICE = "Voice"

static func _play_sound(sound: AudioStream, player, maxDistance:float = 10.0, theBus:String = BUS_SOUNDS):
	player.stream = sound
	player.autoplay = true
	player.bus = theBus
	if((player is AudioStreamPlayer2D) || (player is AudioStreamPlayer3D)):
		player.max_distance = maxDistance

static func playSound(sound: AudioStream, maxDistance:float = 10.0, theBus:String = BUS_SOUNDS) -> AudioStreamPlayer:
	var newPlayer := AudioStreamPlayer.new()
	_play_sound(sound, newPlayer, maxDistance, theBus)
	OPTIONS.get_tree().current_scene.add_child(newPlayer)
	newPlayer.finished.connect(func(): newPlayer.queue_free())
	return newPlayer

static func playSound2D(node:Node2D, sound: AudioStream, maxDistance:float = 10.0, theBus:String = BUS_SOUNDS) -> AudioStreamPlayer2D:
	var newPlayer := AudioStreamPlayer2D.new()
	_play_sound(sound, newPlayer, maxDistance, theBus)
	node.add_child(newPlayer)
	newPlayer.finished.connect(func(): newPlayer.queue_free())
	return newPlayer

static func playSound3D(node:Node3D, sound: AudioStream, maxDistance:float = 10.0, theBus:String = BUS_SOUNDS) -> AudioStreamPlayer3D:
	if(maxDistance < 0.0):
		maxDistance = 10.0
	var newPlayer := AudioStreamPlayer3D.new()
	_play_sound(sound, newPlayer, maxDistance, theBus)
	node.add_child(newPlayer)
	newPlayer.finished.connect(func(): newPlayer.queue_free())
	return newPlayer
