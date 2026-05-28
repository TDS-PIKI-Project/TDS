extends Node2D

var start_time: float

func updateScore(score: int) -> void:
	$ScoreValue.set_text(str(score))

func updateGold() -> void:
	$GoldAmount.set_text(str(GameManager.gold))
	
func setTimer() -> void:
	start_time = Time.get_ticks_msec()

func updateTimer() -> void:
	if GameManager.is_game_active:
		var cur_time = Time.get_ticks_msec()
		var final_time = (cur_time - start_time) / 1000
		var minutes = int(final_time) / 60
		var seconds = int(final_time) % 60
		$TimerCount.set_text("%02d:%02d" % [minutes, seconds])
