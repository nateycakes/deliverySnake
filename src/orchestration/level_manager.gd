extends Node
class_name LevelManager

# this node handles everything from setting up levels to 

signal delivery_success
signal game_over
signal level_complete

@onready var delivery_base_score : float = 2.0
@onready var pickup_scene : PackedScene = preload("res://src/level/pickup.tscn")

@onready var current_scene : Level = null

@onready var tile_size : int = 32

#LEVEL MANAGEMENT VARIABLES
@onready var current_level : Level = null
@onready var level_list : Dictionary

#valid inputs defined as vectors for moving the character around
@onready var inputs = {"right": Vector2.RIGHT,
			"left": Vector2.LEFT,
			"up": Vector2.UP,
			"down": Vector2.DOWN}

# Called when the node enters the scene tree for the first time.
func _ready():
	game_over.connect(set_game_over) #listen for Game Over signal



func _input(event):
	if GameManager.is_game_over and event.is_action_pressed("confirm"):
		GameManager.score_manager.initialize_scores()
		get_tree().reload_current_scene()
		
	return

func intiate_new_game(calling_level : Level):
	current_scene = calling_level
	GameManager.score_manager.initialize_scores()
	GameManager.reset_game_over_status()
	print("new game initialized!")

func set_game_over():
	GameManager.set_game_over()
	print("game is over!")

#unify the gridsnapping somewhere, might as well be for the level
func snap_to_grid(input_position : Vector2):
	#snap the player to the grid (ty kidscancode)
	var return_position = input_position.snapped(Vector2.ONE * tile_size)
	return_position  += Vector2.ONE * tile_size/2
	return return_position
