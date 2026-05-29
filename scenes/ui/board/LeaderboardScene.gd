extends CanvasLayer

@onready var entries_vbox = $Panel/MarginContainer/VBoxContainer/ScrollContainer/EntriesVBox
@onready var http_request = $HTTPRequest
@onready var close_btn = $Panel/MarginContainer/VBoxContainer/CloseBtn

func _ready():
	close_btn.pressed.connect(_on_close_pressed)

	http_request.request_completed.connect(_on_request_completed)

	load_leaderboard()


func load_leaderboard():
	var error = http_request.request(
		GameManager.BASE_URL + "/leaderboard"
	)

	if error != OK:
		print("Ошибка запроса leaderboard: ", error)


func _on_request_completed(result, response_code, headers, body):

	if response_code != 200:
		print("Ошибка сервера: ", response_code)
		return

	var json = JSON.new()

	var parse_result = json.parse(body.get_string_from_utf8())

	if parse_result != OK:
		print("Ошибка JSON")
		return

	var data = json.data

	update_ui(data)


func update_ui(players):

	for child in entries_vbox.get_children():
		child.queue_free()

	var place = 1

	for player in players:

		var panel = PanelContainer.new()

		panel.custom_minimum_size.y = 50

		var hbox = HBoxContainer.new()

		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var place_label = Label.new()
		place_label.text = str(place) + "."
		place_label.custom_minimum_size.x = 40

		var name_label = Label.new()
		name_label.text = player["username"]
		if name_label.text == GameManager.username:
			name_label.modulate = Color(0.4, 1.0, 0.2)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var score_label = Label.new()
		score_label.text = str(player["score"])

		hbox.add_child(place_label)
		hbox.add_child(name_label)
		hbox.add_child(score_label)

		panel.add_child(hbox)

		entries_vbox.add_child(panel)

		place += 1


func _on_close_pressed():
	queue_free()
