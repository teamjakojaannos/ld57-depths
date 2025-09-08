class_name Signals

static func try_connect(_signal, callable: Callable) -> bool:
	if not _signal.is_connected(callable):
		_signal.connect(callable)
		return true

	return false