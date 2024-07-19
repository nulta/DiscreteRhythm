@tool
class_name Note
extends ColorRect


const IDLE_COLOR = Color("#333333")
const ACTIVE_COLOR = Color("#00ffcc")
const UNTRIGGER_ANIM_TIME = 0.2

const SIZE_BASE_NOTE = 130
const SIZE_MARGIN = 10
const SIZE_PER_BAR = (SIZE_BASE_NOTE + SIZE_MARGIN) * 4
const SIZE_ARROW_MAXW = SIZE_BASE_NOTE

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

@export_range(0.0, 1.0)
var trigger: float = 0.0:
	set(value):
		trigger = value
		_update_trigger()

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


func _ready():
	set_process(false)
	_update_note_type()
	_update_trigger()
	_update_size()


func _process(_delta: float):
	_update_color()


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


func _update_trigger():
	if trigger > 0.0:
		set_process(true)
	_update_color()


func _update_color():
	if trigger > 0.0:
		if long_note:
			%LongNoteProgress.value = remap(ease(trigger, 1/5.0), 0.0, 1.0, 0.1, 1.0)
		else:
			color = ACTIVE_COLOR
		%Arrow.modulate = IDLE_COLOR
	else:
		%LongNoteProgress.value = 0.0
		if is_processing():
			color = ACTIVE_COLOR
			%Arrow.modulate = IDLE_COLOR
			var tween = create_tween().set_parallel()
			tween.tween_property(self, "color", IDLE_COLOR, UNTRIGGER_ANIM_TIME)
			tween.tween_property(%Arrow, "modulate", Color.WHITE, UNTRIGGER_ANIM_TIME)
			set_process(false)
		else:
			color = IDLE_COLOR
			%Arrow.modulate = Color.WHITE


func _update_size():
	custom_minimum_size.x = SIZE_PER_BAR * beat_ratio - SIZE_MARGIN
	size.x = custom_minimum_size.x
	size.y = SIZE_BASE_NOTE
	%CenterContainer.custom_minimum_size.x = min(size.x, SIZE_ARROW_MAXW)
