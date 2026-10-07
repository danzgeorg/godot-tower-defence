extends CanvasLayer

func setTowerPreview(towerType,mousePos):
	var dragTower = load("res://scenes/towers/" + towerType + ".tscn").instantiate() #Load the drag towers file path.
	dragTower.set_name("DragTower") #Renames the drag preview.
	dragTower.modulate = Color("#19f012b4")

	var control = Control.new()
	control.add_child(dragTower,true) #Add the drag tower as a child of this new control node.
	control.position = mousePos #The position of the tower is where the mouse cursor is.
	control.set_name("TowerPreview") #This control node should be named tower preview.
	add_child(control,true) #Add that as a child to the canvas layer UI.
	move_child(get_node("TowerPreview"),0)

func updateTowerPreview(newPos,color):
	get_node("TowerPreview").position = newPos
	if get_node("TowerPreview/DragTower").modulate != Color(color):
		get_node("TowerPreview/DragTower").modulate = Color(color)


# These are all the functions for the game controls.
#-------------------------------------------------------------------------------
func _on_Pause_pressed():
	if get_parent().buildMode:
		get_parent().cancelBuildMode()
	if get_tree().paused: 
		get_tree().paused = false #If it is already paused, then unpause
	elif get_parent().currWave == 0 and get_tree().paused == false: 
		get_parent().startNextWave() #If the game has not begun (wave 0) then increment to 1st wave and start.
	else:
			get_tree().paused = true


func _on_Speed_pressed():
	var speedLabel = get_node("HUD/SpeedControl/Label")
	var time = Engine.time_scale
	var newTime = time

	if time == 2:
		newTime = 0.5
	elif time == 0.5:
		newTime = 1
	elif time == 1:
		newTime = 1.5
	elif time == 1.5:
		newTime = 2
	else:
		newTime = 1
		
	Engine.time_scale = newTime
	speedLabel.text = str(newTime) + "x"
#-------------------------------------------------------------------------------
