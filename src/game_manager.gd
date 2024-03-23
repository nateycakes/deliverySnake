extends Node


signal delivery_success
signal game_over

@onready var tile_size : int = 32


@onready var min_value_x : int = 1
@onready var max_value_x : int = 19
@onready var min_value_y : int = 10
@onready var max_value_y : int = 19

@onready var player_score : int = 0
@onready var delivery_base_score : float = 2.0
@onready var pickup_scene : PackedScene = preload("res://src/level/pickup.tscn")

@onready var inputs = {"right": Vector2.RIGHT,
			"left": Vector2.LEFT,
			"up": Vector2.UP,
			"down": Vector2.DOWN}




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func generate_new_pickup_location(excluded_positions : Array) -> Vector2:
	var new_pickup_x : int = randi_range(min_value_x, max_value_x)
	var new_pickup_y : int = randi_range(min_value_y, max_value_y)
	var new_position : Vector2 = Vector2(new_pickup_x,new_pickup_y)
	
	#loop until we find a position that isn't in the excluded list
	while excluded_positions.find(new_position) != -1:
		new_pickup_x = randi_range(min_value_x, max_value_x)
		new_pickup_y = randi_range(min_value_y, max_value_y)
		new_position = Vector2(new_pickup_x,new_pickup_y)
	
	return new_position

