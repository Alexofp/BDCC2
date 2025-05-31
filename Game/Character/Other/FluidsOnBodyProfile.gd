extends RefCounted
class_name FluidsOnBodyProfile

var mess:Array[float] = []

var dirty:float = 0.0

signal onChangeZone(_zone, _newAmount)
signal onChange

func _init() -> void:
	for _zone in FluidsOnBodyZone.getAll():
		mess.append(0.0)

func getMess(_zone:int) -> float:
	if(_zone < 0 || _zone >= FluidsOnBodyZone.getAll().size()):
		return 0.0
	return mess[_zone]

func setMess(_zone:int, _amount:float):
	if(_zone < 0 || _zone >= FluidsOnBodyZone.getAll().size()):
		assert(false, "Bad FluidsOnBody zone "+str(_zone))
		return
	if(mess[_zone] == _amount):
		return
	mess[_zone] = _amount
	if(dirty <= 0.0):
		dirty = 0.2
	onChangeZone.emit(_zone, _amount)
	onChange.emit()

func addMess(_zone:int, _howMuch:float):
	var newAm:float = clamp(getMess(_zone)+_howMuch, 0.0, 1.0)
	setMess(_zone, newAm)

func updateLayeredTexture(_texture:MyLayeredTexture):
	_texture.clearLayers()
	
	var theScrollValue:float = float(hash(self) % 1000)/100.0
	
	var theNoiseTexture:= preload("res://Mesh/Cum/BodyMask/CumNoise.tres")
	
	var chestMess:float = getMess(FluidsOnBodyZone.Chest)
	if(chestMess > 0.0):
		_texture.addSmoothRevealLayer(theNoiseTexture, preload("res://Mesh/Cum/BodyMask/CumMask_Chest.png"), chestMess, 0.1, theScrollValue)
	var buttMess:float = getMess(FluidsOnBodyZone.Butt)
	if(buttMess > 0.0):
		_texture.addSmoothRevealLayer(theNoiseTexture, preload("res://Mesh/Cum/BodyMask/CumMask_Butt.png"), buttMess, 0.1, theScrollValue)
	var backMess:float = getMess(FluidsOnBodyZone.Back)
	if(backMess > 0.0):
		_texture.addSmoothRevealLayer(theNoiseTexture, preload("res://Mesh/Cum/BodyMask/CumMask_Back.png"), backMess, 0.1, theScrollValue)
	var bellyMess:float = getMess(FluidsOnBodyZone.Belly)
	if(bellyMess > 0.0):
		_texture.addSmoothRevealLayer(theNoiseTexture, preload("res://Mesh/Cum/BodyMask/CumMask_Belly.png"), bellyMess, 0.1, theScrollValue)
	var waistMess:float = getMess(FluidsOnBodyZone.Waist)
	if(waistMess > 0.0):
		_texture.addSmoothRevealLayer(theNoiseTexture, preload("res://Mesh/Cum/BodyMask/CumMask_Waist.png"), waistMess, 0.1, theScrollValue)
	var legsMess:float = getMess(FluidsOnBodyZone.Legs)
	if(legsMess > 0.0):
		_texture.addSmoothRevealLayer(theNoiseTexture, preload("res://Mesh/Cum/BodyMask/CumMask_Legs.png"), legsMess, 0.1, theScrollValue)
	var armsMess:float = getMess(FluidsOnBodyZone.Arms)
	if(armsMess > 0.0):
		_texture.addSmoothRevealLayer(theNoiseTexture, preload("res://Mesh/Cum/BodyMask/CumMask_Arms.png"), armsMess, 0.1, theScrollValue)


func saveData() -> Dictionary:
	return {
		mess = mess,
	}

func loadData(_data:Dictionary):
	var hadAnyChange:bool = false
	var newMess:Array = SAVE.loadVar(_data, "mess", [])
	for _i in range(mess.size()):
		var newVal:float = newMess[_i] if (_i <= newMess.size()) else 0.0
		if(newVal != mess[_i]):
			mess[_i] = newVal
			onChangeZone.emit(_i, newVal)
			hadAnyChange = true
	if(hadAnyChange):
		onChange.emit()
