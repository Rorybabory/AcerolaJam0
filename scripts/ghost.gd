extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var time = 0
@export var player : Node3D
var stunRot = 0.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	time += randf()

func when_hit():
	print("Hit ghost")
	stunRot = PI/4

func _physics_process(delta):
	time += delta
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	self.rotation.y = atan2(player.global_position.x-self.global_position.x, 
							player.global_position.z-self.global_position.z)+PI
	self.rotation.y += (sin(time)*0.75 + cos(time * 5) * 0.5)
	var aim = get_global_transform().basis
	var dir = -basis.z * 2
	self.velocity = Vector3(dir.x, self.velocity.y, dir.z)
	if (stunRot > 0.05):
		self.velocity.z = 0
		self.velocity.x = 0

	
	rotation.x = lerp(stunRot, 0.0, delta*10)
	rotation.z = 0
	stunRot = lerp(stunRot, 0.0, delta*5)
	
	move_and_slide()
