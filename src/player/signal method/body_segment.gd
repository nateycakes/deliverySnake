extends Area2D
class_name BodySegment

signal position_updated(new_position)

@onready var previous_segment : BodySegment = null
@onready var next_segment : BodySegment = null

@onready var body_segment_scene : PackedScene = preload("res://src/player/signal method/body_segment.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	snap_to_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func snap_to_grid():
	#snap the player to the grid (ty kidscancode)
	position = position.snapped(Vector2.ONE * GameManager.tile_size)
	position += Vector2.ONE * GameManager.tile_size/2



func has_next_segment() -> bool:
	if next_segment == null:
		return false
	else:
		return true

func has_previous_segment() -> bool:
	if previous_segment != null:
		return true
	else:
		return false

func get_previous_segment() -> BodySegment:
	return previous_segment

func get_next_segment() -> BodySegment:
	return next_segment

func set_previous_segment(input_segment : BodySegment) -> void:
	previous_segment = input_segment

func set_next_segment(input_segment : BodySegment) -> void:
	next_segment = input_segment

func update_next_segment_position( input_position : Vector2) -> void:
	if not has_next_segment():
		return
	next_segment.position = input_position
	

func update_position(input_position : Vector2) -> void:
	position_updated.emit(global_position)
	global_position = input_position
	


func add_next_segment(tail_segment : BodySegment) -> bool:
	
	var new_body_segment : BodySegment = body_segment_scene.instantiate() as BodySegment
	new_body_segment.set_previous_segment(tail_segment)
	tail_segment.set_next_segment(new_body_segment)
	new_body_segment.update_position(tail_segment.global_position)
	
	#new_body_segment.connect("position_updated",func(): new_body_segment.update_position(new_body_segment.position))
	#func(): my_dictionary.clear()

	
	call_deferred("add_child", new_body_segment) #throws a timing/race error if we dont do it this way
	return true



