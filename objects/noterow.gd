@tool
extends HBoxContainer
class_name Noterow


const NOTE_GAP = 10
const NoteScn = preload("res://objects/note.tscn")

@export var semi_rows: Array[SemiNoterow] = []:
	set(value):
		semi_rows = value
		if is_node_ready():
			_create_notes()

@export var prefix_fraction: String = "":
	set(value):
		prefix_fraction = value
		if is_node_ready():
			_update_prefixes()

@export_range(0, 9999)
var prefix_bpm: int = 0:
	set(value):
		prefix_bpm = value
		if is_node_ready():
			_update_prefixes()

@export_range(0.0, 1.0)
var current_beat: float = 0.0:
	set(value):
		current_beat = value
		if is_node_ready():
			_update_active_note()

@export var row_active: bool = false:
	set(value):
		row_active = value
		if is_node_ready():
			_update_active_note()

var _note_references: Array[NoteReference] = []

@onready var note_container := %NoteContainer
@onready var fraction_mark: Label = %FractionMark as Label
@onready var bpm_mark: Label = %BpmMark as Label


func _ready() -> void:
	_create_notes()
	_update_prefixes()
	_update_active_note()


func get_note_ref_table() -> Array[NoteReference]:
	return _note_references


func _update_active_note() -> void:
	for ref in _note_references:
		if row_active and ref.beat_start <= current_beat and current_beat < ref.beat_end:
			ref.node.triggered = true
		else:
			ref.node.triggered = false


func _update_prefixes() -> void:
	if fraction_mark:
		if prefix_fraction:
			fraction_mark.visible = true
			fraction_mark.text = prefix_fraction
		else:
			fraction_mark.visible = false
	
	if bpm_mark:
		if prefix_bpm:
			bpm_mark.visible = true
			bpm_mark.text = str(prefix_bpm) + "BPM"
		else:
			bpm_mark.visible = false	


func _clear_notes() -> void:
	_note_references = []
	for child in note_container.get_children():
		child.queue_free()


func _create_notes() -> void:
	_clear_notes()

	var note_timing := 0.0
	for semirow in semi_rows:
		if not semirow: continue
		note_timing += _create_semi_row(semirow, note_timing)


func _create_semi_row(semi_row: SemiNoterow, beat_start: float) -> float:
	var up_track: HBoxContainer
	var down_track: HBoxContainer
	
	# Is it single-row?
	if semi_row.down.is_empty():
		up_track = (note_container as HBoxContainer)
		down_track = (note_container as HBoxContainer)
	else:
		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", NOTE_GAP)
		
		up_track = HBoxContainer.new()
		up_track.add_theme_constant_override("separation", NOTE_GAP)
		up_track.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vbox.add_child(up_track)
		
		down_track = HBoxContainer.new()
		down_track.add_theme_constant_override("separation", NOTE_GAP)
		down_track.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vbox.add_child(down_track)
		
		note_container.add_child(vbox)
	
	var beat_start_up := beat_start
	for note_data in semi_row.up:
		if not note_data: continue
		_create_note(up_track, note_data, beat_start_up)
		beat_start_up += note_data.beat_ratio

	var beat_start_down := beat_start
	for note_data in semi_row.down:
		if not note_data: continue
		_create_note(down_track, note_data, beat_start_down)
		beat_start_down += note_data.beat_ratio
	
	if beat_start_up != beat_start_down and not semi_row.down.is_empty():
		printerr("NoteRow: beat_start_up != beat_start_down")
	
	return max(beat_start_up, beat_start_down)


func _create_note(parent: Node, note_data: NoteData, beat_start: float) -> void:
	var note := NoteScn.instantiate()
	note.set_from_note_data(note_data)
	parent.add_child(note)
	
	var ref := NoteReference.new()
	ref.beat_start = beat_start
	ref.beat_end = beat_start + note_data.beat_ratio
	ref.node = note as Note
	ref.note_type = note_data.note_type

	_note_references.append(ref)


class NoteReference extends RefCounted:
	var node: Note = null

	## `beat_ratio` value where this note starts at.
	var beat_start: float = 0.0

	## `beat_ratio` value where this note ends at.
	## The length of note is equal to `beat_end - beat_start`.
	var beat_end: float = 0.0
	
	var note_type: NoteData.NoteType = NoteData.NoteType.NONE
