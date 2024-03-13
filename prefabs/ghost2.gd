extends CharacterBody3D

var health = 4
@export var player : Node3D
const SPEED = 4.0
var timer = 0

var mesh

var attackCounter = 0.0
var canAttack = true

func when_hit():
	print("Hit ghost")
	$Audio.play()
	health-=1
func _ready():
	mesh = get_node("MeshInstance3D")

func _process(delta):
	mesh.get_active_material(0).set_shader_parameter("time", timer)
	timer+=delta

func attack():
	player.when_hit(3)
	pass

func _physics_process(delta):
	var targetRotation = atan2(player.global_position.x-self.global_position.x, 
							player.global_position.z-self.global_position.z)+PI
	
	targetRotation += sin(timer*4.0) * 0.7
	self.rotation.y = targetRotation
	var dir = -basis.z * SPEED
	self.velocity = Vector3(dir.x, self.velocity.y, dir.z)
	if (health <= 0):
		queue_free()
	pass
	var dist = global_position.distance_to(player.global_position)
	if (canAttack and dist < 1.3):
		canAttack = false
		attack()
	
	if (not canAttack):
		attackCounter += delta
		if (attackCounter > 1.0):
			canAttack = true
			attackCounter = 0
	
	move_and_slide()
