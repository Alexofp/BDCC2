extends AIActionBase

var taskID:int = -1

func _init() -> void:
	id = "Obey"

func start(_args:Array):
	taskID = getPawn().submission.obeyTask

func processAction(_dt:float):
	pass

func think():
	var thePawn := getPawn()
	var theSubmission:SubmissionHandler = thePawn.submission
	
	if(!theSubmission.isObeying()):
		completeAction()
		return
	
	if(taskID != theSubmission.obeyTask):
		taskID = theSubmission.obeyTask
		replan()

func plan() -> AIPlan:
	var thePawn := getPawn()
	var theSubmission:SubmissionHandler = thePawn.submission
	var theDomPawn := theSubmission.obeyPawn
	if(!theSubmission.isObeying() || !theDomPawn):
		return null
	
	var theTaskID:int = theSubmission.obeyTask
	if(theTaskID == ObeyTask.Look):
		return makePlan().add("Face", [theDomPawn])
	if(theTaskID == ObeyTask.Follow):
		return makePlan().add("Follow", [theDomPawn])
	
	return null
	
	
