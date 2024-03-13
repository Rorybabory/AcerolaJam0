extends Node3D
@export var player : Node3D

@export var spawnPoints: Array[Node3D]
@export var ghosts: Array[PackedScene]
var spawnInterval = 12.0
var spawnCount = 10.0



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func spawnEnemy():
	var index = randi_range(0, spawnPoints.size()-1)
	print("spawn enemy at point: " + str(spawnPoints[index].global_position))
	var ghostIndex = randi_range(0, ghosts.size()-1)
	
	var ghost = ghosts[ghostIndex].instantiate()
	get_tree().root.get_child(0).add_child(ghost)
	var forward = -get_global_transform().basis.z
	ghost.global_position = spawnPoints[index].global_position
	ghost.player = player
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	spawnCount += delta
	
	if (spawnCount > spawnInterval):
		spawnEnemy()
		spawnInterval *= 0.8
		if (spawnInterval < 2):
			spawnInterval = 2
		spawnCount = 0
	pass
