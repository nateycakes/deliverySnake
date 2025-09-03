extends Node2D

@onready var return_button: Button = $WinGraphicsLayer/CenterContainer/ControlsContainer/ReturnButton



func _ready() -> void:
	return_button.grab_focus()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("confirm") && return_button.has_focus():
		var new_title_screen = GameManager.title_screen_scene.instantiate()
		GameManager.call_deferred("add_child", new_title_screen)
		call_deferred("queue_free")
