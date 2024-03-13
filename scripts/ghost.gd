extends CharacterBody3D

enum STATE {IDLE, WALK, THROW}

const SPEED = 1.0
const JUMP_VELOCITY = 4.5
var time = 0
var throwtimer = 0
var throwmax = 0
@export var player : Node3D
var stunRot = 0.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var projectile


var animPlayer

var health = 5
var dead = false

var state = STATE.WALK

var thrown = false

var mesh

func _ready():
	mesh = get_node("Model/RootNode/ghost/Skeleton3D/Ghost")
	time += randf()
	animPlayer = get_node("Model/AnimationPlayer")
	throwmax = randf_range(1.0, 2.5)
	projectile = preload("res://prefabs/projectile.tscn")
func when_hit():
	print("Hit ghost")
	stunRot = PI/4
	$Audio.play()
	health-=1
	

func walk_state(delta):
	
	animPlayer.current_animation = "ghost|GhostWalk"
	self.rotation.y = atan2(player.global_position.x-self.global_position.x, 
							player.global_position.z-self.global_position.z)+PI
	self.rotation.y += (sin(time)*0.75 + cos(time * 5) * 0.5)
	var aim = get_global_transform().basis
	var dir = -basis.z * SPEED
	self.velocity = Vector3(dir.x, self.velocity.y, dir.z)
	if (stunRot > 0.05):
		self.velocity.z = 0
		self.velocity.x = 0
	throwtimer+=delta
	if (throwtimer > throwmax):
		throwtimer = 0
		state = STATE.THROW
		animPlayer.current_animation = "ghost|GhostThrow"

func spawn_projectile():
	var proj = projectile.instantiate()
	get_tree().root.get_child(0).add_child(proj)
	var forward = -get_global_transform().basis.z
	proj.global_position = global_position + Vector3(0, 1.3, 0) + Vector3(forward.x*1.0, 0, forward.z*1.0).normalized()
	proj.velocity = Vector3(forward.x, 0, forward.z).normalized() * 15
	


func throw_state(delta):
	velocity.x = 0
	velocity.z = 0
	self.rotation.y = atan2(player.global_position.x-self.global_position.x, 
							player.global_position.z-self.global_position.z)+PI
	if (animPlayer.current_animation_position > 1.3 and thrown == false):
		thrown = true
		spawn_projectile()
		print("Throw")
	if (not animPlayer.is_playing()):
		thrown = false
		state = STATE.WALK
func _physics_process(delta):
	if (dead == false):
		time += delta
	mesh.get_active_material(0).set_shader_parameter("time", time)
	if (health <= 0 ):
		if (dead == false):
			animPlayer.current_animation = "ghost|GhostDeath"
			if (animPlayer.current_animation_position >= 0.14):
				animPlayer.pause()
				$CollisionShape3D.disabled = true
				dead = true
				rotation.x = 0
				move_and_slide()
		else:
			rotation.x = 0
		return
	


	match state:
		STATE.IDLE:
			pass
		STATE.WALK:
			walk_state(delta)
		STATE.THROW:
			throw_state(delta)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	

	
	rotation.x = lerp(stunRot, 0.0, delta*10)
	rotation.z = 0
	stunRot = lerp(stunRot, 0.0, delta*5)
	
	move_and_slide()
