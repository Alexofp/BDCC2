extends Node3D

@onready var doll: Doll = $Doll
@onready var doll_2: Doll = $Doll2

var someCharacter:BaseCharacter = BaseCharacter.new()

func _ready():
	doll_2.setCharacter(someCharacter)
	

func setChar(theChar:BaseCharacter):
	doll.setCharacter(theChar)
	#doll_2.setCharacter(theChar)
	
	doll.alignPenisToAnus(doll_2)

func _process(_delta: float) -> void:
	#print(_delta)
	
	if(Input.is_key_pressed(KEY_1)):
		doll.alignPenisToVagina(doll_2)
	if(Input.is_key_pressed(KEY_2)):
		doll.alignPenisToAnus(doll_2)
	#if(Input.is_key_pressed(KEY_3)):
	#	queue_free()


func _on_interactable_on_interact(user: Node3D, action: InteractAction) -> void:
	if(action.id == "nya"):
		user.global_position = global_position
