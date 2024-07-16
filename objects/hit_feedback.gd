extends Node2D

const HitDetail = JudgementEngine.HitDetail

var hit: HitDetail = HitDetail.PERFECT
var time: float = 0.0

func _ready() -> void:
	match hit:
		HitDetail.PERFECT:
			%Text.text = "Perfect!"
			%Text.modulate = Color("#00ffcc")
		HitDetail.GREAT:
			%Text.text = "Great"
			%Text.modulate = Color("#00ccff")
			%Particle.amount = 12
		HitDetail.BAD:
			%Text.text = "Bad"
			%Text.modulate = Color("#ffffff")
			%Particle.amount = 6
		HitDetail.MISS:
			%Text.text = "Miss"
			%Text.modulate = Color("#ff3333")
			%Particle.visible = false
			%Offset.visible = false
	%Offset.text = ("+" if time > 0 else "") + str(round(time * 1000))
	%Particle.emitting = true

	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART).set_parallel()
	tween.tween_property(%Text, "position:y", %Text.position.y - 100, 2)
	tween.tween_property(%Text, "modulate:a", 0, 1.5).set_delay(0.5)
	tween.chain().tween_callback(queue_free)
