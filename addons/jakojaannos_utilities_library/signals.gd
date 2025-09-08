@tool
class_name Signals

static func try_connect(_signal, callable: Callable) -> bool:
	if not _signal.is_connected(callable):
		_signal.connect(callable, ConnectFlags.CONNECT_PERSIST)
		return true

	return false