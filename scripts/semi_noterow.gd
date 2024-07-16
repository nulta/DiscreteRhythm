class_name SemiNoterow
extends Resource

@export var up: Array[NoteData] = []
@export var down: Array[NoteData] = []

func is_single() -> bool:
	return down.is_empty()
