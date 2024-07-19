extends Node2D


const HitFeedback = preload("res://objects/hit_feedback.tscn")
const NoteType = NoteData.NoteType
const HitDetail = JudgementEngine.HitDetail

@export var bpm: int = 145
@export var current_time: float = 0.0
@export var beats_per_bar: int = 4

var _time_music_begin: float = 0.0
var _time_music_delay: float = 0.0
var _time_offset: float = 0.0

var _judge: = JudgementEngine.new()
@onready var _noteboard: = %Noteboard
@onready var _music_player: = %MusicPlayer
@onready var _camera: = %Camera
@onready var _hit_feedbacks: = %HitFeedbacks


func _ready() -> void:
	_initialize_judgement_engine()
	_initialize_music()


func _process(_delta: float) -> void:
	_process_time()
	_process_notes()
	_process_camera()
	_process_debug_keypress()
	_judge.process(current_time)


func _initialize_music() -> void:
	_time_music_begin = Time.get_ticks_usec()
	_time_music_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	_music_player.play()


func _initialize_judgement_engine() -> void:
	var judgement_table: Array[JudgementItem] = []
	var timing: = 0.0
	var time_per_row: = 1.0/bpm * 60.0 * beats_per_bar

	for row: Noterow in _noteboard.get_children():
		var refs = row.get_note_ref_table()

		var judges = refs.map(func(x: Noterow.NoteReference):
			var judge = JudgementItem.new()
			judge.start_time = timing + (x.beat_start * time_per_row)
			judge.end_time = timing + (x.beat_end * time_per_row)
			judge.key = x.note_type
			judge.long_note = x.node.long_note
			judge.node = x.node
			return judge
		).filter(func(x): return x.key != NoteData.NoteType.NONE)
		judges.sort_custom(func(a, b): return a.start_time < b.start_time)

		judgement_table.append_array(judges)
		timing += time_per_row

	_judge.initialize(judgement_table)
	_judge.hitted.connect(_handle_note_hit)


func _process_time() -> void:
	if not _music_player.playing: return
	var clock = (Time.get_ticks_usec() - _time_music_begin) / 1_000_000.0
	current_time = max(0, clock - _time_music_delay + _time_offset)


func _process_notes() -> void:
	var current_row: = _get_current_row()
	var current_row_node: = _get_nth_row_node(current_row)
	var previous_row_node: = _get_nth_row_node(current_row - 1)

	if current_row_node:
		current_row_node.row_active = true
		current_row_node.current_beat = _get_row_progress()

	if previous_row_node:
		previous_row_node.row_active = false


func _process_camera() -> void:
	var current_row_node = _get_nth_row_node(_get_current_row())
	_camera.focus_node = current_row_node


func _process_debug_keypress() -> void:
	var time_per_row: = 1.0/bpm * 60.0 * beats_per_bar
	var playback_add_time: = 0.0

	if Input.is_action_just_pressed("playback_forward"):
		playback_add_time += time_per_row
	
	if Input.is_action_just_pressed("playback_backward"):
		playback_add_time -= time_per_row
	
	if playback_add_time:
		_time_music_begin -= playback_add_time * 1_000_000.0
		_music_player.seek(_music_player.get_playback_position() + playback_add_time)

	if Input.is_action_just_pressed("playback_pause"):
		if _music_player.stream_paused:
			_music_player.stream_paused = false
			_time_music_begin = Time.get_ticks_usec() - (_music_player.get_playback_position() * 1_000_000.0)
			_time_music_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
		else:
			_music_player.stream_paused = true


func _handle_note_hit(detail: HitDetail, t: float, node: Note) -> void:
	var focus_pos: = node.global_position + (node.size / 2)

	# Initialize feedback particles
	var feedback: = HitFeedback.instantiate()
	feedback.hit = detail
	feedback.time = t
	_hit_feedbacks.add_child(feedback)
	feedback.global_position = focus_pos

	# Shake camera
	if detail > HitDetail.BAD:
		_camera.punch_to()


func _get_current_row() -> int:
	return floor(current_time/60 * bpm / beats_per_bar)


func _get_row_progress() -> float:
	return fmod(current_time/60 * bpm / beats_per_bar, 1.0)


func _get_nth_row_node(n: int) -> Noterow:
	var row_counts = _noteboard.get_child_count(false)

	if n >= row_counts:
		return null
	else:
		return _noteboard.get_child(n) as Noterow
