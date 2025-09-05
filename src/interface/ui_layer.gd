extends CanvasLayer
class_name UILayer

signal next_level_requested
signal begin_level_requested

@onready var score_label_container = $ScoreLabelContainer
@onready var score_label = $ScoreLabelContainer/VBoxContainer/ScoreLabel

@onready var game_over_container = $GameOverContainer
@onready var final_score_label = $GameOverContainer/VBoxContainer/FinalScoreLabel
@onready var menu_button = $GameOverContainer/VBoxContainer/MenuButton
@onready var game_over_text = $GameOverContainer/VBoxContainer/GameOverText
@onready var game_over_background = $GameOverBackground

@onready var level_victory_container: CenterContainer = $LevelVictoryContainer
@onready var continue_button: Button = $LevelVictoryContainer/VBoxContainer/ContinueButton
@onready var trips_count_label: Label = $LevelVictoryContainer/VBoxContainer/ScoreHBoxContainer/TripsVboxContainer/TripsCount

@onready var level_start_container: CenterContainer = $LevelStartContainer
@onready var level_identifier_label: Label = $LevelStartContainer/VBoxContainer/LevelIdentifierLabel
@onready var delivery_count_label: Label = $LevelStartContainer/VBoxContainer/DeliveryCountLabel
@onready var start_level_button: Button = $LevelStartContainer/VBoxContainer/StartLevelButton




@onready var game_over_focus : bool = false




# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.level_manager.delivery_success.connect(_on_score_update) #we want to call the function, not run it!
	GameManager.level_manager.game_over.connect(_on_game_over)
	game_over_background.visible = false
	game_over_container.visible = false
	level_victory_container.visible = false
	level_start_container.visible = false
	return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	#game_over_focus will only be true when there's a game over
	if GameManager.is_game_over and event.is_action_pressed("confirm"):
		GameManager.score_manager.initialize_scores()
		#get_tree().reload_current_scene()
	
	if level_victory_container.visible && continue_button.has_focus() && event.is_action_pressed("confirm"):
		#the victory screen is visible, the continue button has focus, and the player hit enter
		next_level_requested.emit()
	
	if level_start_container.visible && start_level_button.has_focus() && event.is_action_pressed("confirm"):
		#level start objective screen visible, and has focus, yadda yadda
		level_begin_pressed()
	
	return




func _on_score_update() -> void :
	score_label.text = "Score: " + str(GameManager.score_manager.level_score)
	return

func toggle_score_visibility() -> void :
	score_label_container.visible = !score_label_container.visible
	return

func _on_game_over() -> void :
	score_label_container.visible = false
	GameManager.score_manager.prepare_final_score()
	final_score_label.text = "Final Score: " + str(GameManager.score_manager.player_game_score)
	game_over_container.visible = true
	game_over_background.visible = true
	menu_button.grab_focus()
	return


func display_level_results(delivery_count : int, trip_count : int) -> void:
	#this will be called by the level itself once the victory conditions are met
	trips_count_label.text = str(trip_count)
	level_victory_container.visible = true
	game_over_background.visible = true
	continue_button.grab_focus()
	
	return

#prepare the beginning objective screen for the level
func prepare_level_start(level_number : int, delivery_count : int): #assume the game will be paused
	game_over_background.visible = true
	level_identifier_label.text = "level " + str(level_number)
	delivery_count_label.text = str(delivery_count)
	level_start_container.visible = true
	start_level_button.grab_focus()

func level_begin_pressed():
	begin_level_requested.emit()
	level_start_container.visible = false
	game_over_background.visible = false

func _on_retry_button_focus_entered():
	game_over_focus = true
	return


func _on_retry_button_focus_exited():
	game_over_focus = false
	return


func _on_retry_button_pressed() -> void:
	GameManager.restart_entire_game()
