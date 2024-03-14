extends Area2D
class_name PlayerBody

signal position_updated
signal head_changed

@onready var head_position
@onready var tail_position

@onready var head_node = null
@onready var tail_node = null
@onready var can_deliver = false

# Called when the node enters the scene tree for the first time.
func _ready():
	snap_to_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func snap_to_grid():
	#snap the player to the grid (ty kidscancode)
	global_position = global_position.snapped(Vector2.ONE * GameManager.tile_size)
	global_position += Vector2.ONE * GameManager.tile_size/2


func get_tail_node():
	return tail_node
func set_tail_node(new_tail):
	tail_node = new_tail

func get_head_node():
	return head_node

func set_head_node(new_head):
	head_node = new_head
	head_changed.emit()


func is_deliverable()-> bool:
	return can_deliver


func _on_area_entered(area):
	if area is DeliveryZone:
		can_deliver = true




func _on_area_exited(area):
	if area is DeliveryZone:
		can_deliver = false
