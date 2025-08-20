extends Node
# here's where I'd list the class name but it conflicts with the Global Namespace, so GUESS WE'LL DEAL WITH IT
#
# This node will handle transitioning the player from title screen to game over, and do it _gracefully_
#

@onready var level_manager: LevelManager = $LevelManager



@onready var inputs = {"right": Vector2.RIGHT,
			"left": Vector2.LEFT,
			"up": Vector2.UP,
			"down": Vector2.DOWN}



func _ready() -> void:
	pass
