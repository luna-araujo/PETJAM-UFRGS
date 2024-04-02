@tool
extends Node

func _get_tool_buttons() -> Array:
	return [
		{call=_randomize, text="Randomize buildings", tint=Color.RED}
	]

func _randomize():
	var buildings: Array[Building] = []
	getBuildings(get_parent(), buildings)
	for building in buildings:
		building._randomize()

func getBuildings(node: Node, output: Array):
	if node is Building:
		output.append(node as Building)
	for child in node.get_children(false):
		getBuildings(child, output)
