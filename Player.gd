
extends CharacterBody3D

enum GUN {PISTOL, SHOTGUN}
const GRAVITY = 9.81

var mouseDelta
var speed = 7.0
var mouse_sens = 0.1
var gun
var animPlayer
@onready var head = $head

var gameoverPos

var gunPos
var scopePos
var gunOffset = 0
var ammo = 10

var headbob = 0.0

var recoil = 0.0

var headbobTimer = 0.0
var reloading = false

var gunBase

var scopeIn = false

var camera

var screenshake = Vector3(0,0,0)
var shake_value = 0
var health = 10.0
var healthbar

var alive = true

var activeGun = GUN.SHOTGUN


# Called when the node enters the scene tree for the first time.
func _ready():

	mouseDelta = Vector2(0,0)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	gunBase = get_node("head/Camera3D/Pistol")
	animPlayer = get_node("head/Camera3D/Pistol/AnimationPlayer")
	gun = get_node("head/Camera3D/Pistol/RootNode")
	gunPos = get_node("head/Camera3D/GunPos")
	scopePos = get_node("head/Camera3D/ScopePos")
	camera = get_node("head/Camera3D")
	healthbar = get_node("Healthbar/Bar")
	gameoverPos = $GameOver.global_position
	$GameOver.global_position = Vector2(0,-1000)
	animPlayer.stop()
	pass # Replace with function body.

func when_hit(damage):
	print("HIT PLAYER")
	shake_value = damage*4
	health -= damage
	pass

func _physics_process(delta):
	if (alive == false):
		$GameOver.global_position = lerp($GameOver.global_position, gameoverPos, delta*10)
		if Input.is_action_just_pressed("move_jump"):
			get_tree().reload_current_scene()
		return
	velocity.y -= GRAVITY * get_process_delta_time()
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized());
	head.rotation.z = lerp(head.rotation.z, -input_dir.x*0.065, delta*5.0);
	recoil = lerp(recoil, 0.0, delta*2.5)
	headbobTimer +=delta
	if (direction):
		var lerpspeed = 6
		if (not is_on_floor()):
			lerpspeed = 4
		velocity.x = lerpf(velocity.x, direction.x * speed, delta*lerpspeed)
		velocity.z = lerpf(velocity.z, direction.z * speed, delta*lerpspeed)
		var headbob_target = 0
		if (is_on_floor()):
			
			headbob_target = sin(headbobTimer*15.0) * 0.08
		else:
			headbob_target = velocity.y*0.05
		headbob = lerp(headbob, headbob_target, delta * 14)
		
	else:
		if (is_on_floor()):	
			velocity.x = lerpf(velocity.x, 0, delta*13)
			velocity.z = lerpf(velocity.z, 0, delta*13)
		else:
			velocity.x = lerpf(velocity.x, 0, delta*2)
			velocity.z = lerpf(velocity.z, 0, delta*2)
		headbob = lerpf(headbob, 0, delta*15)
	if (Input.is_action_just_pressed("move_jump") and is_on_floor()):
		velocity.y = 4
	move_and_slide()
func _input(event):
	if event is InputEventMouseMotion:
		if (alive == false):
			return
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		var range = (3.1415/2.0)*0.85
		if (head.rotation.x > range):
			head.rotation.x = range
		if (head.rotation.x < -range):
			head.rotation.x = -range
		
func gunRaycast():
	var space_state = get_world_3d().direct_space_state
	var aim = camera.get_global_transform().basis
	var forward = -aim.z
	var query = PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position+forward*300)
	var result = space_state.intersect_ray(query)
	if (result):
		#print("position:" + str(result.position))
		#print("hit object: " + str(result.collider))
		if (result.collider.has_method("when_hit")):
			result.collider.when_hit()
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if (alive == false):
		rotation.z = lerp(rotation.z, -PI*0.5, delta*5)
		return
	
	if (activeGun == GUN.SHOTGUN):
		#get_node("head/Camera3D/Pistol").set_visible(false)
		pass
	
	
	screenshake = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * delta
	head.position.y = 1.5+headbob
	head.position.x = 0
	head.position.z = 0
	head.position += screenshake * shake_value
	shake_value = lerpf(shake_value, 0.0, delta*4.5)
	head.get_node("Camera3D").rotation.x = recoil
	healthbar.scale.x = health/10.0
	if (scopeIn):
		gunBase.position = gunBase.position.lerp(scopePos.position, delta * 10);
		gunBase.rotation = scopePos.rotation;
		camera.fov = lerp(camera.fov, 40.0, delta*7.0)
	else:
		gunBase.position = gunBase.position.lerp(gunPos.position + Vector3(0, headbob + sin(headbobTimer*1.3)*0.03, 0), delta * 10);
		
		gunBase.rotation = gunPos.rotation;

		camera.fov = lerp(camera.fov, 95.0, delta*7.0)
	var animPos = 0
	
	if (health <= 0):
		alive = false
		

	
	if (animPlayer.current_animation == ""):
		animPos = 0
	else:
		animPos = animPlayer.current_animation_position
	if (Input.is_action_pressed("alt_fire")):
		scopeIn = true
		
	else:
		scopeIn = false
	if (Input.is_action_just_pressed("fire") and reloading == false and (animPos == 0 or animPos > 0.2)):
		animPlayer.stop(true)
		animPlayer.play("Armature|Fire")
		recoil += 0.12
		ammo-=1
		$Audio.pitch_scale = 1.0 + randf_range(-0.01, 0.01)
		$Audio.play()
		gunRaycast()
	if (Input.is_action_just_pressed("pause")):
		if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		pass
	if (reloading and animPlayer.current_animation != "Armature|Fire"):
		animPlayer.play("Armature|Reload")
	if ((ammo <= 0 or Input.is_action_just_pressed("reload")) and reloading == false):
		reloading = true;
		$Crosshair.hide()
	
	if (reloading == true and animPlayer.current_animation_position > 1.7):
		ammo = 10
		reloading = false
		$Crosshair.show()
	$number.number = ammo


