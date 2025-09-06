extends Node
#class_name GameManager (I just need this to be here for my own sanity lol)
# here's where I'd list the class name but it conflicts with the Global Namespace, so GUESS WE'LL DEAL WITH IT
#
# This node will handle transitioning the player from title screen to game over, and do it _gracefully_
#

signal game_over
signal out_of_lives

enum DIFFICULTY {
	EASY,
	NORMAL,
	HARD
}

@onready var title_screen_scene : PackedScene = preload("res://src/orchestration/title_screen.tscn")
@onready var win_screen_scene : PackedScene = preload("res://src/orchestration/win_screen.tscn")

@onready var level_manager: LevelManager = $LevelManager
@onready var score_manager: ScoreManager = $ScoreManager

@onready var is_game_over : bool = false
@onready var is_game_paused : bool = false #used for the pause menu in the level UI

#the GameManager will track how many chances the player gets, since the player will transition between
#levels, we need to centralize this
### PLAYER MANAGEMENT  ###
@onready var player_lives_by_difficulty : Dictionary = {
	GameManager.DIFFICULTY.EASY : 10,
	GameManager.DIFFICULTY.NORMAL : 5,
	GameManager.DIFFICULTY.HARD : 1
}
@onready var player_lives_max : int = 1 
@onready var player_lives_current : int = 1



func _ready() -> void:
	pass

func new_game_setup(difficulty):
	
	match difficulty:
		GameManager.DIFFICULTY.EASY:
			player_lives_max = 10
			
	
	player_lives_current = player_lives_max
	reset_game_over_status()

func player_death_signal_catcher():
	player_lives_current -= 1;
	if player_lives_current <= 0:
		out_of_lives.emit()
		set_game_over()
		

func set_game_over():
	is_game_over = true
	game_over.emit()

func on_game_over():
	pass

func restart_entire_game():
	reset_game_over_status()
	level_manager.delete_active_level()
	var menu_scene_template = preload("res://src/orchestration/title_screen.tscn")
	var menu_scene = menu_scene_template.instantiate()
	add_child(menu_scene)

func reset_game_over_status():
	is_game_over = false
