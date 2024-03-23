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
	GameManager.delivery_success.connect(_on_score_update) #we want to call the function, not run it!
	GameManager.game_over.connect(_on_game_over)
	game_over_background.visible = false
	game_over_container.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	#game_over_focus will only be true when there's a game over
	if game_over_focus and event.is_action_pressed("confirm"):
		get_tree().reload_current_scene()




func _on_score_update() -> void :
	score_label.text = "Score: " + str(GameManager.player_score)

func toggle_score_visibility() -> void :
	score_label_container.visible = !score_label_container.visible

func _on_game_over() -> void :
	score_label_container.visible = false
	final_score_label.text = "Final Score: " + str(GameManager.player_score)
	game_over_container.visible = true
	game_over_background.visible = true
	retry_button.grab_focus()
	







func _on_retry_button_focus_entered():
	game_over_focus = true


func _on_retry_button_focus_exited():
	game_over_focus = false









