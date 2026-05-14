extends Object
class_name Audio

const BUS_SOUNDS = "Sounds"
const BUS_VOICE = "Voice"

static var streamPool3D:Array[AudioStreamPlayer3D] = []

static func _play_sound(sound: AudioStream, player, maxDistance:float = 20.0, theBus:String = BUS_SOUNDS):
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

static func playSoundAdvanced(sound: AudioStream, volumeInc:float = 0.0, pitch:float = 1.0, theBus:String = BUS_SOUNDS) -> AudioStreamPlayer:
	var newPlayer := AudioStreamPlayer.new()
	_play_sound(sound, newPlayer, 20.0, theBus)
	newPlayer.volume_db += volumeInc
	newPlayer.pitch_scale = pitch
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
	#print(streamPool3D)
	var newPlayer:AudioStreamPlayer3D = AudioStreamPlayer3D.new() if streamPool3D.is_empty() else streamPool3D.pop_back()
	_play_sound(sound, newPlayer, maxDistance, theBus)
	node.add_child(newPlayer)
	newPlayer.finished.connect(onStreamFinished.bind(newPlayer))
	newPlayer.max_db = 0.0
	newPlayer.pitch_scale = 1.0
	newPlayer.attenuation_model = AudioStreamPlayer3D.ATTENUATION_DISABLED
	return newPlayer

static func playSound3DAdvanced(node:Node3D, sound: AudioStream, volumeInc:float = 0.0, pitch:float = 1.0, maxDistance:float = 10.0, theBus:String = BUS_SOUNDS) -> AudioStreamPlayer3D:
	if(maxDistance < 0.0):
		maxDistance = 10.0
	var newPlayer:AudioStreamPlayer3D = AudioStreamPlayer3D.new() if streamPool3D.is_empty() else streamPool3D.pop_back()
	_play_sound(sound, newPlayer, maxDistance, theBus)
	node.add_child(newPlayer)
	newPlayer.finished.connect(onStreamFinished.bind(newPlayer))
	newPlayer.volume_db = volumeInc
	#newPlayer.max_db -= volumeInc
	newPlayer.pitch_scale = pitch
	newPlayer.attenuation_model = AudioStreamPlayer3D.ATTENUATION_DISABLED
	newPlayer.max_db = 0.0
	return newPlayer

static func onStreamFinished(newPlayer:AudioStreamPlayer3D):
	if(newPlayer.is_queued_for_deletion()):
		return
	newPlayer.finished.disconnect(onStreamFinished.bind(newPlayer))
	var theParent:Node = newPlayer.get_parent()
	if(theParent):
		theParent.remove_child(newPlayer)
	streamPool3D.append(newPlayer)
