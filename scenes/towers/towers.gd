extends Node2D

var type
var enemyArray = []
var built = false
var enemy
var isReady = true

func _ready():
	if built:
		self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * GameData.towerData[type]["range"]
#		Get the range of the tower from the towerData dictionary and halve it, getting the radius.

func _physics_process(_delta):
	if not built:
		return
	if enemyArray.size() != 0 and built: #If there are enemies in the array and the tower is built.
		selectEnemy()
		turn()
		if isReady:
			shoot()
	else:
		enemy = null
	
func selectEnemy():
	var progressionArray = [] #Array of the offsets of every enemy.
	for anEnemy in enemyArray:
		progressionArray.append(anEnemy.progress) #Append the offsets for every enemy
	var maximumOffset = progressionArray.max() #Set the maximum offset (furthest along the path)
	var enemyIndex = progressionArray.find(maximumOffset) #Find the index where that is.
	enemy = enemyArray[enemyIndex] #Use that index to find the enemy to target.
	
func turn():
	var characterWeapon = get_node("character+weapon")
	if enemy.global_position.x < global_position.x:
		characterWeapon.scale.x = -abs(characterWeapon.scale.x)
	else:
		characterWeapon.scale.x = abs(characterWeapon.scale.x)

func shoot():
	if enemy == null or not is_instance_valid(enemy):
		return
	isReady = false
	enemy.hit(GameData.towerData[type]["damage"])
	await get_tree().create_timer(GameData.towerData[type]["firerate"]).timeout
	isReady = true
	
func _on_Range_body_entered(body):
	enemyArray.append(body.get_parent()) #Append the enemy to the enemy array as it enters the towers' range.

func _on_Range_body_exited(body):
	enemyArray.erase(body.get_parent()) #Erase the enemy from the enemy array as it exits the towers' range.
