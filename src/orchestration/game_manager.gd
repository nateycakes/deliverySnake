extends Node
# here's where I'd list the class name but it conflicts with the Global Namespace, so GUESS WE'LL DEAL WITH IT
#
# This node will handle transitioning the player from title screen to game over, and do it _gracefully_
#

@onready var level_manager: LevelManager = $LevelManager
@onready var score_manager: ScoreManager = $ScoreManager

@onready var is_game_over : bool = false

func _ready() -> void:
	pass


func set_game_over():
	is_game_over = true


func reset_game_over_status():
	is_game_over = false
