extends Node

var left_keys:  = Array("qwertasdfgzxcvb".split()).map(OS.find_keycode_from_string)
var right_keys: = Array("yuiophjkl;nm,./".split()).map(OS.find_keycode_from_string)
var space_keys: = [KEY_SPACE]
var key_dict: Dictionary = {}

const LEFT_KEY = "left_action"
const RIGHT_KEY = "right_action"
const SPACE_KEY = "space_action"


func _init() -> void:
	for key in left_keys: key_dict[key] = LEFT_KEY
	for key in right_keys: key_dict[key] = RIGHT_KEY
	for key in space_keys: key_dict[key] = SPACE_KEY
	
	for key in key_dict:
		var ev: = InputEventKey.new()
		ev.keycode = key
		InputMap.action_add_event(key_dict[key], ev)


func _unhandled_key_input(event: InputEvent) -> void:
	var key: = event as InputEventKey
	if not key: return

	# TODO TODO TODO TODO TODO TODO TODO TODO
	var key_type = key_dict.get(key.keycode)
	match key_type:
		null: pass
		LEFT_KEY: pass
		RIGHT_KEY: pass
		SPACE_KEY: pass
