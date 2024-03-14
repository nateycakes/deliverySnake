extends Area2D
class_name Pickup


signal collected

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


