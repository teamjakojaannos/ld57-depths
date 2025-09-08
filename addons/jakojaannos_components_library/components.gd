class_name Components

## Attempts to connect a callable [param fn] to a signal of given
## [param signal_name] on a component with class with matching
## [param component_name]. Components are searched from children
## of a provided root [param node].[br]
## [br]
## Does nothing if the signal is already connected to the given
## callable or if a component with given name cannot be found.[br]
## [br]
## If component instance is already available,
## [member Components.try_connect_to] can be used instead.
static func try_connect(node: Node, component_name: String, signal_name: String, fn: Callable) -> void:
	var component = Nodes.find_by_class(node, component_name)
	if component is Node:
		if not component.is_connected(signal_name, fn):
			component.connect(signal_name, fn, ConnectFlags.CONNECT_PERSIST)


## Attempts to connect a callable [param fn] to a signal of given
## [param signal_name] on the [param component].[br]
## [br]
## Does nothing if the signal is already connected to the given
## callable.[br]
## [br]
## If the component instance is not yet available, but the class is
## known, use [member Components.try_connect] instead.
static func try_connect_to(component: Node, signal_name: String, fn: Callable) -> void:
	if component is Node:
		if not component.is_connected(signal_name, fn):
			component.connect(signal_name, fn, ConnectFlags.CONNECT_PERSIST)


## Sets the value of the given [param property] to a sibling component
## of the [param component] if the property is currently not set. Tries
## to [member Components.find] a sibling component with class matching
## [param component_name].[br]
## [br]
## Useful for setting a default value of an exported component property
## in a [member _ready] func. Shorthand for:
## [codeblock]
## Components.set_default(node, "property", Components.find(node.get_parent(), "ComponentClass"
## [/codeblock]
## Equivalent to a null-coalescing assignment on the [param property],
## with the new value being a sibling component of given type.[br]
## [br]
## See also [member Components.set_default]
static func set_default_sibling(node: Node, property: String, component_name: String) -> void:
	var existing = node.get("property")
	if existing != null and Nodes.match_by_class_name(existing, component_name):
		return

	var component = Nodes.find_by_class(node.get_parent(), component_name)
	if component != null:
		node.set(property, component)


## Sets the value of the given [param property] on the [param node]
## if the property value is currently not set. Useful for setting a
## default value of an exported component property in a [code]_ready[/code]
## func.[br]
## [br]
## Equivalent to a null-coalescing assignment on the [param property].[br]
## [br]
## See also [member Components.set_default_sibling]
static func set_default(node: Node, property: String, component: Node) -> void:
	var existing = node.get(property)
	if existing == null and component is Node:
		node.set(property, component)
