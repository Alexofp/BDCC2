extends VarUIBase

@onready var voice_info_label: RichTextLabel = %VoiceInfoLabel
@onready var voice_selector: OptionButton = %VoiceSelector
@onready var pitch_slider: VBoxContainer = %PitchSlider

var voiceProfile:VoiceProfile = VoiceProfile.new()
var voicesAr:Array = []

func _ready() -> void:
	pitch_slider.setData({
		name = "Pitch",
		value = 1.0,
		min = 0.8,
		max = 1.2,
	})
	
	voice_selector.clear()
	for voiceID in GlobalRegistry.getSexVoices():
		var theVoice:SexVoiceBase = GlobalRegistry.getSexVoice(voiceID)
		voice_selector.add_item(theVoice.getName())
		voicesAr.append(voiceID)

func setData(_data:Dictionary):
	if(_data.has("name")):
		$HBoxContainer/Label.text = _data["name"]
	if(_data.has("tooltip")):
		tooltip_text = _data["tooltip"]
	if(_data.has("value")):
		voiceProfile.loadData(_data["value"].duplicate(true))
		
		pitch_slider.setData({
			name = "Pitch",
			value = voiceProfile.getVoicePitch(),
			min = 0.8,
			max = 1.2,
		})
		
		var _i:int = 0
		for voiceID in voicesAr:
			if(voiceID == voiceProfile.getSexVoiceID()):
				voice_selector.select(_i)
			_i += 1
		updateVoiceInfo()

func _on_voice_selector_item_selected(index: int) -> void:
	if(index < 0 || index >= voicesAr.size()):
		return
	voiceProfile.setSexVoice(voicesAr[index])
	updateVoiceInfo()
	triggerChange(voiceProfile.saveData().duplicate(true))

func updateVoiceInfo():
	if(voiceProfile.getSexVoiceID() == "" || voiceProfile.getSexVoice() == null):
		voice_info_label.text = ""
		return
	
	var theVoice:SexVoiceBase = voiceProfile.getSexVoice()
	var theTexts:Array = [theVoice.getName()]
	if(!theVoice.getVoiceActors().is_empty()):
		theTexts.append("Voice by:")
	for actorID in theVoice.getVoiceActors():
		var voiceActor:VoiceActor = GlobalRegistry.getVoiceActor(actorID)
		if(!voiceActor):
			theTexts.append(actorID+" (Missing credentials)")
		else:
			var theLinks:Dictionary = voiceActor.getLinks()
			var linksFinal:Array = []
			for linkName in theLinks:
				linksFinal.append("[url="+theLinks[linkName]+"]"+linkName+"[/url]")
			if(!linksFinal.is_empty()):
				theTexts.append(voiceActor.getName()+" ("+Util.join(linksFinal, ", ")+")")
			else:
				theTexts.append(voiceActor.getName())
	voice_info_label.text = Util.join(theTexts, "\n")


func _on_preview_button_pressed() -> void:
	voiceProfile.playPreview()

func _on_voice_info_label_meta_clicked(meta: Variant) -> void:
	var _ok := OS.shell_open(str(meta))

func _on_pitch_slider_on_value_change(_id: Variant, newValue: float) -> void:
	voiceProfile.setVoicePitch(newValue)
	
	triggerChange(voiceProfile.saveData().duplicate(true))
