extends RefCounted
class_name JudgementEngine

signal hitted(detail: HitDetail, time_offset: float, note: Note)


const NoteType = NoteData.NoteType

enum HitDetail {
	MISS,
	BAD,
	GREAT,
	PERFECT,
}

var max_time_margin: float     = 4/24.0
var time_margin_bad: float     = 3/24.0
var time_margin_great: float    = 2/24.0
var time_margin_perfect: float = 1/24.0

var judgement_time_offset = -0.02

var _judgement_table: Array[JudgementItem] = []
var _judgement_current: Array[JudgementItem] = []


func initialize(judgement_table: Array[JudgementItem]) -> void:
	_judgement_table = judgement_table
	_judgement_current = []


func _get_current_press() -> Dictionary:
	return {
		NoteType.LEFT: Input.is_action_just_pressed("left_action"),
		NoteType.LEFT_DOUBLE: Input.is_action_just_pressed("left_action"),  # TODO
		NoteType.RIGHT: Input.is_action_just_pressed("right_action"),
		NoteType.RIGHT_DOUBLE: Input.is_action_just_pressed("right_action"),  # TODO
		NoteType.SPACE: Input.is_action_just_pressed("space_action"),
		NoteType.LEFT_RIGHT:
			Input.is_action_just_pressed("left_action")
			and Input.is_action_just_pressed("right_action"),
	}


func _get_current_hold() -> Dictionary:
	return {
		NoteType.LEFT: Input.is_action_pressed("left_action"),
		NoteType.LEFT_DOUBLE: Input.is_action_pressed("left_action"),  # TODO
		NoteType.RIGHT: Input.is_action_pressed("right_action"),
		NoteType.RIGHT_DOUBLE: Input.is_action_pressed("right_action"),  # TODO
		NoteType.SPACE: Input.is_action_pressed("space_action"),
		NoteType.LEFT_RIGHT:
			Input.is_action_pressed("left_action")
			and Input.is_action_pressed("right_action"),
	}


func process(current_time: float) -> void:
	current_time += judgement_time_offset
	
	# Update current_judgement
	while not _judgement_table.is_empty():
		var judge: = _judgement_table[0]
		if (judge.start_time - max_time_margin) <= current_time:
			_judgement_current.push_back(judge)
			_judgement_table.erase(judge)
		else:
			break

	# Update current input
	var current_press: = _get_current_press()
	var current_hold: = _get_current_hold()

	# Process current_judgement
	for judge: JudgementItem in _judgement_current.duplicate():
		# 1-1. Long note holding
		if judge.long_note and current_hold[judge.key]:
			if (judge.end_time + max_time_margin) < current_time:
				# Held too long
				_judgement_current.erase(judge)
				miss(max_time_margin, judge)
				continue
			else:
				# Holding...
				continue

		# 1-2. Not held long note
		# Note: Wrongly released long notes are processed at (2)
		if judge.long_note and (judge.end_time - max_time_margin) < current_time:
			_judgement_current.erase(judge)
			handle_hit(current_time - judge.end_time, judge)
			continue

		# 2. Miss the note
		if (judge.start_time + max_time_margin) < current_time:
			_judgement_current.erase(judge)
			miss(max_time_margin, judge)
			continue

		# 3. Hit the note
		if current_press[judge.key]:
			_judgement_current.erase(judge)
			handle_hit(current_time - judge.start_time, judge)
			continue


func miss(time_offset: float, item: JudgementItem) -> void:
	hitted.emit(HitDetail.MISS, time_offset, item.node)


func handle_hit(time_offset: float, item: JudgementItem) -> void:
	var abs_time = abs(time_offset)

	if abs_time <= time_margin_perfect:
		hitted.emit(HitDetail.PERFECT, time_offset, item.node)
	elif abs_time <= time_margin_great:
		hitted.emit(HitDetail.GREAT, time_offset, item.node)
	elif abs_time <= time_margin_bad:
		hitted.emit(HitDetail.BAD, time_offset, item.node)
	else:
		miss(time_offset, item)
