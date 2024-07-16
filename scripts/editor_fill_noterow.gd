@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	for node in get_all_children(get_scene()):
		var noterow: = node as Noterow
		if not noterow: continue
		if noterow.owner != get_scene(): continue
		if not noterow.semi_rows.is_empty(): continue
		
		var semirow: = SemiNoterow.new()
		semirow.up = [
			NoteData.new(),
			NoteData.new(),
			NoteData.new(),
			NoteData.new(),
		]
		noterow.semi_rows.append(semirow)


func get_all_children(in_node, children_acc = []):
	children_acc.push_back(in_node)
	for child in in_node.get_children():
		children_acc = get_all_children(child, children_acc)

	return children_acc
