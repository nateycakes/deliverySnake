extends CanvasLayer
class_name UILayer

@onready var score_label_container = $ScoreLabelContainer
@onready var score_label = $ScoreLabelContainer/VBoxContainer/ScoreLabel

@onready var game_over_container = $GameOverContainer
@onready var final_score_label = $GameOverContainer/VBoxContainer/FinalScoreLabel
@onready var retry_button = $GameOverContainer/VBoxContainer/RetryButton
@onready var game_over_text = $GameOverContainer/VBoxContainer/GameOverText
@onready var game_over_background = $GameOverBackground

@onready var game_over_focus : bool = false




# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.level_manager.delivery_success.connect(_on_score_update) #we want to call the function, not run it!
	GameManager.level_manager.game_over.connect(_on_game_over)
	game_over_background.visible = false
	game_over_container.visible = false
	return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	#game_over_focus will only be true when there's a game over
	if GameManager.is_game_over and event.is_action_pressed("confirm"):
		GameManager.score_manager.initialize_scores()
		get_tree().reload_current_scene()
		
	return




func _on_score_update() -> void :
	score_label.text = "Score: " + str(GameManager.score_manager.player_current_score)
	return

func toggle_score_visibility() -> void :
	score_label_container.visible = !score_label_container.visible
	return

func _on_game_over() -> void :
	score_label_container.visible = false
	GameManager.score_manager.prepare_final_score()
	final_score_label.text = "Final Score: " + str(GameManager.score_manager.player_total_score)
	game_over_container.visible = true
	game_over_background.visible = true
	retry_button.grab_focus()
	return







func _on_retry_button_focus_entered():
	game_over_focus = true
	return


func _on_retry_button_focus_exited():
	game_over_focus = false
	return
