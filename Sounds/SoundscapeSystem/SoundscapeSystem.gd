extends Node3D
class_name SoundscapeSystem

const TIME_BETWEEN_SOUNDS_MIN := 10.0
const TIME_BETWEEN_SOUNDS_MAX := 120.0

const TIME_BETWEEN_AMBIENCE_SWITCH_MIN := 30.0
const TIME_BETWEEN_AMBIENCE_SWITCH_MAX := 120.0

const AMBIENCE_FADE_TIME := 5.0

const SOUND_RANDOM_RANGE_MIN := 20.0
const SOUND_RANDOM_RANGE_MAX := 50.0

var ambientEntries:Array[AmbientEntry]
var ambientSounds:Array[AmbientSoundEntry]

var currentSoundscapeResource:SoundscapeResource
@onready var switch_ambience_timer: Timer = %SwitchAmbienceTimer
@onready var soundscape_detector: Area3D = %SoundscapeDetector
@onready var ambient_sound_timer: Timer = %AmbientSoundTimer

func _ready() -> void:
	currentSoundscapeResource = preload("res://Sounds/SoundscapeSystem/Soundscapes/TestSoundscape.tres")
	playRandomAmbient()
	resetAmbienceTimer()
	resetRandomSoundTimer()

class AmbientSoundEntry:
	var sound:AudioStreamPlayer3D
	signal onRemove(entry:AmbientSoundEntry)

	func play(_soundStream:AudioStream, _system:SoundscapeSystem):
		sound = AudioStreamPlayer3D.new()
		sound.stream = _soundStream
		sound.pitch_scale = RNG.randfRange(0.7, 1.3)
		_system.add_child(sound)
		sound.bus = "AmbientSounds"
		sound["parameters/looping"] = false
		sound.finished.connect(removeMe)
		
		sound.global_position = SoundscapeSystem.randomPositionOnRadius(_system.soundscape_detector.global_position, RNG.randfRange(SOUND_RANDOM_RANGE_MIN, SOUND_RANDOM_RANGE_MAX), 0.25)
		sound.play()
	
	func removeMe():
		onRemove.emit(self)

class AmbientEntry:
	var sound:AudioStreamPlayer
	var volumeTween:Tween
	var isFading:bool = false
	
	signal onRemove(entry:AmbientEntry)
	
	func play(_soundStream:AudioStream, _system:SoundscapeSystem):
		sound = AudioStreamPlayer.new()
		sound.stream = _soundStream
		_system.add_child(sound)
		sound.bus = "Ambient"
		sound["parameters/looping"] = true
		var theLen:float = sound.stream.get_length()
		sound.volume_linear = 0.0
		sound.pitch_scale = RNG.randfRange(0.5, 1.5)
		if(volumeTween):
			volumeTween.kill()
		volumeTween = sound.create_tween()
		volumeTween.tween_property(sound, "volume_linear", RNG.randfRange(0.5, 1.0), AMBIENCE_FADE_TIME)
		sound.play(RNG.randfRange(0.0, theLen*0.9))
	
	func fadeAway():
		if(isFading):
			return
		if(volumeTween):
			volumeTween.kill()
		volumeTween = sound.create_tween()
		volumeTween.tween_property(sound, "volume_linear", 0.0, AMBIENCE_FADE_TIME)
		volumeTween.tween_callback(removeMe)
		isFading = true
	
	func removeMe():
		onRemove.emit(self)

func setSoundscapeResource(_res:SoundscapeResource):
	if(currentSoundscapeResource == _res):
		return
	currentSoundscapeResource = _res
	fadeAwayAllAmbients()
	playRandomAmbient()

func playRandomAmbient():
	if(!currentSoundscapeResource || currentSoundscapeResource.ambiences.is_empty()):
		return
	var randomStream:AudioStream = RNG.pick(currentSoundscapeResource.ambiences)
	if(!randomStream):
		return
	var newAmbient := AmbientEntry.new()
	ambientEntries.append(newAmbient)
	newAmbient.onRemove.connect(onAmbientFinished)
	newAmbient.play(randomStream, self)

func playRandomSound():
	if(!currentSoundscapeResource || currentSoundscapeResource.randomNoises.is_empty()):
		return
	var randomStream:AudioStream = RNG.pick(currentSoundscapeResource.randomNoises)
	if(!randomStream):
		return
	var newSound := AmbientSoundEntry.new()
	ambientSounds.append(newSound)
	newSound.onRemove.connect(onRandomSoundFinished)
	newSound.play(randomStream, self)

func onRandomSoundFinished(_theSound:AmbientSoundEntry):
	ambientSounds.erase(_theSound)

func onAmbientFinished(_theEntry:AmbientEntry):
	ambientEntries.erase(_theEntry)

func fadeAwayAllAmbients():
	var amAmount:int = ambientEntries.size()
	for _i in amAmount:
		var _indx:int = amAmount - 1 - _i
		ambientEntries[_indx].fadeAway()

func _on_switch_ambience_timer_timeout() -> void:
	fadeAwayAllAmbients()
	playRandomAmbient()
	resetAmbienceTimer()

func resetAmbienceTimer():
	switch_ambience_timer.start(RNG.randfRange(TIME_BETWEEN_AMBIENCE_SWITCH_MIN, TIME_BETWEEN_AMBIENCE_SWITCH_MAX))

func getCameraPosition() -> Vector3:
	var theCam := get_viewport().get_camera_3d()
	if(!theCam):
		return Vector3(11110.0, -99999.9, -1230.0)
	return theCam.global_position

func _physics_process(_delta: float) -> void:
	var thePos := getCameraPosition()
	soundscape_detector.global_position = thePos

func _on_ambient_sound_timer_timeout() -> void:
	playRandomSound()
	resetRandomSoundTimer()

func resetRandomSoundTimer():
	ambient_sound_timer.start(RNG.randfRange(TIME_BETWEEN_SOUNDS_MIN, TIME_BETWEEN_SOUNDS_MAX))

static func randomPositionOnRadius(center: Vector3, radius: float, ysquish:float = 1.0) -> Vector3:
	return center + Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0),	randf_range(-1.0, 1.0)).normalized() * radius * Vector3(1.0, ysquish, 1.0)
