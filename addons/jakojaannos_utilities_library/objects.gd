@tool
class_name Objects

## tool-safe null check, resilient to non-tool script instances evaluating to
## Object#null -abominations, which seemingly, in some cases, pass the regular
## `node != null` -checks.[br]
## [br]
## Prefer this over regular null checks in tool-scripts.
static func is_null(value: Object) -> bool:
	return value is not Object
