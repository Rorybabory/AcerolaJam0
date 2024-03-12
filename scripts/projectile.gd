extends Area3D

var velocity

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector3(0,0,0)
	pass # Replace with function body.

func body_entered(area):
	print("destroyed")
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.y -= 9.81 * delta * 0.2
	global_position += velocity * delta
	

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	#print("destroyed")
	queue_free()
	if (body.name == "Player"):
		body.when_hit(randf_range(1, 4))
	pass # Replace with function body.
