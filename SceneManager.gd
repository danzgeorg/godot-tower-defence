extends Node
var gameScene
func _ready():
	loadMainMenu()

func loadMainMenu():
	get_node("Main Menu/TRect/TRect/MainMenu/Play").connect("pressed", Callable(self, "onPlayPressed"))
	get_node("Main Menu/TRect/TRect/MainMenu/Options").connect("pressed", Callable(self, "onOptionsPressed"))
	get_node("Main Menu/TRect/TRect/MainMenu/Quit").connect("pressed", Callable(self, "onQuitPressed"))

func onPlayPressed():
	get_node("Main Menu").queue_free()
	gameScene = load("res://scenes/main_scenes/Game.tscn").instantiate()
	gameScene.connect("gameOver", Callable(self, "_onGameOver"))
	add_child(gameScene)
	
func onOptionsPressed():
	pass
	
func onQuitPressed():
	get_tree().quit()

func _onGameOver(_result):
	get_node("Game").queue_free()
	var mainMenu = load("res://scenes/main_scenes/MainMenu.tscn").instantiate()
	add_child(mainMenu)
	loadMainMenu()
