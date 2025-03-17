extends Node3D
class_name AnimSceneBase

func unsitThing(_theThing):
	return

func applyAnimPlayer(user: DollController, theAnimPlayer:AnimationMixer):
	theAnimPlayer.root_node = theAnimPlayer.get_path_to(user.getBodySkeleton())
