@tool
class_name Signals

static func try_connect(s: Signal, callable: Callable) -> bool:
	if not s.is_connected(callable):
		s.connect(callable, ConnectFlags.CONNECT_PERSIST)
		return true

	return false
