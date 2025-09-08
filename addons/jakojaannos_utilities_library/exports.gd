class_name Exports

static func visible_if(property: Dictionary, condition: bool, mask: int) -> void:
	property.usage = Bitflags.cond(condition, property.usage, mask)