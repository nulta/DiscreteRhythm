@tool
class_name Note
extends ColorRect

const idle_color = Color("#333333")
const active_color = Color("#00ffcc")
const untrigger_anim_time = 0.1

const px_base_note = 130
const px_margin = 10
const px_per_bar = (px_base_note + px_margin) * 4
const px_arrow_max_width = px_base_note


@export_range(0, 2)
var left_note: int = 0:
	set(value):
		left_note = value
		_update_note_type()

@export_range(0, 2)
var right_note: int = 0:
	set(value):
		right_note = value
		_update_note_type()

@export_range(0, 1)
var space_note: int = 0:
	set(value):
		space_note = value
		_update_note_type()

@export var long_note: bool = false:
	set(value):
		long_note = value
		_update_note_type()

@export var triggered: bool = false:
	set(value):
		triggered = value
		_update_triggered()

@export_range(0.0, 1.0, 1/32.0)
var beat_ratio: float = 1/4.0:  # <-- 1/4 beat
	set(value):
		beat_ratio = value
		_update_size()

@export
var text: String = "":
	set(value):
		text = value
		_update_note_type()

var _triggered_transition: float = 0.0;


func set_from_note_data(note_data: NoteData) -> void:
	beat_ratio = note_data.beat_ratio
	long_note = note_data.long_note
	text = note_data.text
	
	const NoteType = NoteData.NoteType
	match note_data.note_type:
		NoteType.LEFT:
			left_note = 1
		NoteType.LEFT_DOUBLE:
			left_note = 2
		NoteType.RIGHT:
			right_note = 1
		NoteType.RIGHT_DOUBLE:
			right_note = 2
		NoteType.LEFT_RIGHT:
			left_note = 1
			right_note = 1
		NoteType.SPACE:
			space_note = 1
		NoteType.NONE:
			pass

func _update_note_type():
	%Arrow/Left1.visible = left_note >= 1
	%Arrow/Left2.visible = left_note >= 2
	%Arrow/Right1.visible = right_note >= 1
	%Arrow/Right2.visible = right_note >= 2
	%Arrow/Space.visible = space_note
	%LongNoteIdentifier.visible = long_note
	%Text.text = text

func _update_triggered():
	if triggered:
		_triggered_transition = 1.0
	else:
		set_process(true)		
	_update_color()

func _update_color():
	color = idle_color.lerp(active_color, _triggered_transition)
	%Arrow.modulate = Color.WHITE.lerp(idle_color, _triggered_transition)
	if _triggered_transition == 0.0:
		set_process(false)

func _update_size():
	custom_minimum_size.x = px_per_bar * beat_ratio - px_margin
	size.x = custom_minimum_size.x
	size.y = px_base_note
	%CenterContainer.custom_minimum_size.x = min(size.x, px_arrow_max_width)

func _ready():
	set_process(false)
	_update_note_type()
	_update_triggered()
	_update_size()

func _process(delta: float):
	_triggered_transition -= delta / untrigger_anim_time
	_triggered_transition = max(0.0, _triggered_transition)
	_update_color()