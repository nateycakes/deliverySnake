extends Node2D


@onready var new_game_button: Button = $TitleScreenUI/CenterContainer/PanelContainer/HBoxContainer/VBoxContainer/NewGameButton
@onready var quit_button: Button = $TitleScreenUI/CenterContainer/PanelContainer/HBoxContainer/VBoxContainer/QuitButton



func _on_new_game_button_pressed() -> void:
	GameManager.level_manager.set_up_first_level(GameManager.DIFFICULTY.NORMAL)
	print("new game started")
	call_deferred("queue_free")



func _on_quit_button_pressed() -> void:
	print("quitting game")
	get_tree().quit()
