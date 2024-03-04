extends TextureRect

var number = 4
var timer = 0.0


var textures = [
	preload("res://textures/numbers/0.png"),
	preload("res://textures/numbers/1.png"),
	preload("res://textures/numbers/2.png"),
	preload("res://textures/numbers/3.png"),
	preload("res://textures/numbers/4.png"),
	preload("res://textures/numbers/5.png"),
	preload("res://textures/numbers/6.png"),
	preload("res://textures/numbers/7.png"),
	preload("res://textures/numbers/8.png"),
	preload("res://textures/numbers/9.png")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	texture = textures[number]

	if (number == -1):
		hide()
	else:
		show()
	pass
