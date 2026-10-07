extends Node2D
signal gameOver(_result)

var level

var buildMode = false
var validBuild = false
var buildLocation
var buildType

var currWave = 0
var totalWaves = 3

var currCurrency = 200
var baseHealth = 100

var enemyWaveCount = 10

func _ready():
	level = get_node("Level1") #Turn the level into a variable.
	
	for i in get_tree().get_nodes_in_group("build_options"): # Retrieves an array of references.
		i.pressed.connect(activateBuildMode.bind(i.get_name())) #Connect pressed state to the function
		# activateBuildMode(towerType). Gets the name of the actual tower from the Vbox container to be selected.
	updateCurrencyDisplay()
	updateWaveDisplay()

func _process(_delta):
	if buildMode:
		updateTowerPreview() #Only if in build mode then we can run updateTowerPreview().

func _unhandled_input(event):
	if event.is_action_released("ui_cancel") and buildMode == true:
		cancelBuildMode()
	elif event.is_action_released("ui_accept") and buildMode == true:
		checkAndBuild()
	elif event.is_action_pressed("ui_home"):
		emit_signal("gameOver",true)

# These are all the functions which are for the wave mechanics.
#-------------------------------------------------------------------------------
func startNextWave():
	await get_tree().create_timer(5*currWave).timeout # Intermission between waves. Multipled by currWave
#	to give player time to kill the remaining enemies.
	currWave += 1 # Increment the wave counter
	updateWaveDisplay() # Update the wave display
	
	if currWave <= totalWaves:
		spawnEnemies("base_orc", currWave * enemyWaveCount) #Spawn correct enemy count
	elif currWave > totalWaves:
		emit_signal("gameOver",true) #End the game

func spawnEnemies(enemyType, count):
	for _i in range(count):
		var enemyScene = load("res://scenes/enemies/" + enemyType + ".tscn")  # Load the enemy scene
		var enemyInstance = enemyScene.instantiate()  # Instance an enemy
		enemyInstance.connect("enemyDied", Callable(self, "_onEnemyDied"))
		enemyInstance.connect("baseDamage", Callable(self, "_onBaseDamage"))
		level.get_node("EnemyPath").add_child(enemyInstance, true)
		await get_tree().create_timer(0.5).timeout  # Wait for half a second
	# When all enemies of a wave are spawned, this will check if there are more waves to go
	if currWave <= totalWaves:
		startNextWave() #Start next wave when enemies are spawned.
#-------------------------------------------------------------------------------
		
# These are the all the functions for the building mechanics.
#-------------------------------------------------------------------------------
func activateBuildMode(towerType):
	if validBuild:
		cancelBuildMode() #Cancel build mode if we are already in build mode from a previous click on buy.
	buildType = (towerType + "L1").strip_edges() #Get the tower's name and level that the player clicks on.
	buildMode = true
	get_node("UI").setTowerPreview(buildType,get_global_mouse_position()) #Build a new function under the CanvasLayer
	#node UI which takes in buildType and the cursor's position.
	
func updateTowerPreview():
	var mousePos = get_global_mouse_position()
	var currTile = level.get_node("TowerExclusion").local_to_map(mousePos) #Get the tile
	var newCell = Vector2(204, 104) * 0.05 #Calculate fraction of individual cell
	var tilePos = level.get_node("TowerExclusion").map_to_local(currTile) + newCell #Center the tower's texture
#   with the postion in the tile.

	var onExclusion = level.get_node("TowerExclusion").get_cell_source_id(0, currTile) != -1
	var onDecoration = level.get_node("Decorations").get_cell_source_id(0, currTile) != -1

	if not onExclusion and not onDecoration: #If there is nothing on the tile.
		get_node("UI").updateTowerPreview(tilePos, "19f012b4") #Green
		validBuild = true
		buildLocation = tilePos
	else:
		get_node("UI").updateTowerPreview(tilePos, "f01912b4") #Red
		validBuild = false
	
func cancelBuildMode():
	buildMode = false
	validBuild = false
	get_node("UI/TowerPreview").free() #Tower is not red or green so comes off the screen.

func checkAndBuild():
	if validBuild and not isTileOccupied(buildLocation):
		#The constants for the cost are defined.
		var cost = 0
		if buildType == "ArcherL1":
			cost = GameData.ARCHER_TOWER_COST
		elif buildType == "WizardL1":
			cost = GameData.WIZARD_TOWER_COST

		if currCurrency >= cost:
			var path = "res://scenes/towers/" + buildType + ".tscn"
			var newTowerScene = load(path)
			var newTower = newTowerScene.instantiate()
			newTower.position = buildLocation
			newTower.built = true
			newTower.type = buildType
			var towersNode = get_node("Level1/Towers")
			towersNode.add_child(newTower) #Add tower to the towers in the level1 scene.
			currCurrency -= cost
			updateCurrencyDisplay()
#------------------------------------------------------------------------------

#Functions to update displays.
#------------------------------------------------------------------------------
func updateCurrencyDisplay():
	var currencyLabel = get_node("UI/HUD/Currency")
	currencyLabel.text = str(currCurrency)
		
func _onBaseDamage(damage): 
	baseHealth -= damage
	if baseHealth <= 0:
		emit_signal("gameOver",true)
	else:
		var healthLabel = get_node("UI/HUD/Health")
		healthLabel.text = str(baseHealth) + "/100"

func _onEnemyDied():
	currCurrency += 20
	updateCurrencyDisplay()

func updateWaveDisplay():
	var waveLabel = get_node("UI/HUD/WaveNumber")
	waveLabel.text = "Wave %d/%d" % [currWave, totalWaves]
#	---------------------------------------------------------------------------

func isTileOccupied(tilePos):
	for tower in get_node("Level1/Towers").get_children():
		if tower.position == tilePos:
			return true
	return false
