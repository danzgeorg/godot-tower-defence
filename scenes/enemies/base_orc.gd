extends PathFollow2D

signal baseDamage(damage)
var speed = 125
var hp = 25
var damageAmount = 20

@onready var healthBar = get_node("HealthBar")
@onready var body = get_node("CharacterBody2D")

signal enemyDied

func _ready():
	self.rotates = false
	healthBar.max_value = hp
	healthBar.value = hp

func _physics_process(delta):
	if progress_ratio == 1.0: #Meaning at the end of the path.
		emit_signal("baseDamage",damageAmount)
		queue_free()
	move(delta) #Move the enemy with delta (time elapsed since last call)

func move(delta):
	var prevX = global_position.x
	progress += speed * delta # Get the coordinates,
#	multiply to get speed during this delta (time), and sum to get change in coordinates.
	var newX = global_position.x
	if newX < prevX:
		body.scale.x = abs(body.scale.x)
	elif newX > prevX:
		body.scale.x = -abs(body.scale.x)

func hit(damage):
	hp -= damage
	healthBar.value = hp
	if hp <= 0:
		emit_signal("enemyDied")
		die()

func die():
	self.queue_free()
