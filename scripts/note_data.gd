class_name NoteData
extends Resource

enum NoteType {
	NONE = 0,
	LEFT,
	RIGHT,
	SPACE,
	LEFT_DOUBLE,
	RIGHT_DOUBLE,
	LEFT_RIGHT,
}

@export_range(0.0, 1.0, 1/32.0)
var beat_ratio: float = 1/4.0

@export var long_note: bool = false
@export var note_type: NoteType = NoteType.NONE
@export var text: String = ""
