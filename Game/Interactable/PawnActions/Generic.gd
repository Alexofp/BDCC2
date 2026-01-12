extends PawnActionBase

# Just passes all the checks to the prop handler

const ARG_ACTION = 0
const ARG_ARGS = 1

func _init() -> void:
	id = "Generic"

func getVisibleName(_context:PawnActionContext) -> String:
	return _context.target.getGenericActionName(_context.getArg(ARG_ACTION, ""), _context.getArg(ARG_ARGS, []), _context, self)

func canDoAction(_context:PawnActionContext) -> bool:
	return _context.target.canDoGenericAction(_context.getArg(ARG_ACTION, ""), _context.getArg(ARG_ARGS, []), _context, self)

func doAction(_context:PawnActionContext) -> bool:
	return _context.target.doGenericAction(_context.getArg(ARG_ACTION, ""), _context.getArg(ARG_ARGS, []), _context, self)

func canDoDelayedAction(_context:PawnActionContext) -> bool:
	return _context.target.canDoGenericDelayedAction(_context.getArg(ARG_ACTION, ""), _context.getArg(ARG_ARGS, []), _context, self)

func doDelayedAction(_context:PawnActionContext) -> bool:
	return _context.target.doGenericDelayedAction(_context.getArg(ARG_ACTION, ""), _context.getArg(ARG_ARGS, []), _context, self)
