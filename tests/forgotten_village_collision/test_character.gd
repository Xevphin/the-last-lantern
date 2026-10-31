extends CharacterBody2D

@export var speed: float = 180.0

func _physics_process(_delta: float) -> void:
	var direction := Vector2(
		float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
		float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
	)
	velocity = direction.normalized() * speed
	move_and_slide()
