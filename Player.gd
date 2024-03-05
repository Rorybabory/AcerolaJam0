
extends CharacterBody3D

const GRAVITY = 9.81

var mouseDelta
var speed = 7.0
var mouse_sens = 0.1
var gun
var animPlayer
@onready var head = $head
var gunOffset = 0
var ammo = 10

var headbob = 0.0

var recoil = 0.0

var headbobTimer = 0.0
var reloading = false

# Called when the node enters the scene tree for the first time.
func _ready():
	mouseDelta = Vector2(0,0)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animPlayer = get_node("head/Camera3D/Gun/AnimationPlayer")
	gun = get_node("head/Camera3D/Gun/RootNode")
	pass # Replace with function body.
	
func _physics_process(delta):
 
	velocity.y -= GRAVITY * get_process_delta_time()
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized());
	head.rotation.z = lerp(head.rotation.z, -input_dir.x*0.065, delta*5.0);
	recoil = lerp(recoil, 0.0, delta*10)
	if (direction):
		var lerpspeed = 6
		if (not is_on_floor()):
			lerpspeed = 4
		velocity.x = lerpf(velocity.x, direction.x * speed, delta*lerpspeed)
		velocity.z = lerpf(velocity.z, direction.z * speed, delta*lerpspeed)
		var headbob_target = 0
		if (is_on_floor()):
			headbobTimer +=delta
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
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		var range = (3.1415/2.0)*0.85
		if (head.rotation.x > range):
			head.rotation.x = range
		if (head.rotation.x < -range):
			head.rotation.x = -range
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	head.position.y = 1.5+headbob;
	head.get_node("Camera3D").rotation.x = recoil
	gun.position.y = headbob*1.0
	var animPos = animPlayer.current_animation_position
	print("head rotation: " + str(head.rotation))
	if (Input.is_action_just_pressed("fire") and reloading == false and (animPos == 0 or animPos > 0.25)):
		animPlayer.stop(true)
		animPlayer.play("Armature|Fire")
		recoil += 0.1
		ammo-=1
		$Audio.pitch_scale = 1.0 + randf_range(-0.01, 0.01)
		$Audio.play()
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


