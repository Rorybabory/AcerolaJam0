extends Node2D

var number = 15

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$digit1.number = number%10
	if (number/10 == 0):
		$digit2.number = -1
	else:
		$digit2.number = number/10
	pass
