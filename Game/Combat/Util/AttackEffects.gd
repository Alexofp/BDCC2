extends RefCounted
class_name AttackEffects

# Info about all the visual/audio flair like particles or the impact sound

const SOUND_SILENCE := 0
const SOUND_PUNCH := 1
const SOUND_KICK := 2

var impactSound:int = SOUND_SILENCE

const ZONE_FIST_LEFT := 0
const ZONE_FIST_RIGHT := 1
const ZONE_FOOT_LEFT := 2
const ZONE_FOOT_RIGHT := 3
const ZONE_KNEE_LEFT := 4
const ZONE_KNEE_RIGHT := 5

var zoneAttacking:int = ZONE_FIST_LEFT

const EFFECT_NO_EFFECT := 0
const EFFECT_IMPACT := 1

var impactEffect:int = EFFECT_NO_EFFECT

const STATUS_HIT := 0
const STATUS_BLOCKED := 1
const STATUS_MISSED := 2

static func create(_sound:int = SOUND_SILENCE, _zone:int = ZONE_FIST_LEFT, _effect:int = EFFECT_NO_EFFECT) -> AttackEffects:
	var theEffect := AttackEffects.new()
	theEffect.impactSound = _sound
	theEffect.zoneAttacking = _zone
	theEffect.impactEffect = _effect
	return theEffect
static func createEmpty() -> AttackEffects:
	var theEffect := AttackEffects.new()
	return theEffect

func setImpactSound(_s:int) -> AttackEffects:
	impactSound = _s
	return self
func setZoneAttacking(_s:int) -> AttackEffects:
	zoneAttacking = _s
	return self
func setImpactEffect(_s:int) -> AttackEffects:
	impactEffect = _s
	return self

static func getEffectTimeMultFromZone(_zone:int) -> float:
	if(_zone == ZONE_FOOT_LEFT || _zone == ZONE_FOOT_RIGHT):
		return 3.0
	return 1.0

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.U8, impactSound,
		Bins.U8, zoneAttacking,
		Bins.U8, impactEffect,
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	impactSound = _data.readU8()
	zoneAttacking = _data.readU8()
	impactEffect = _data.readU8()
	_data.endLoad()
