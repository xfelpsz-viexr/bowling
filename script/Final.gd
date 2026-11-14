extends Control

func _on_Reiniciar_btn_pressed():
	get_tree().change_scene("res://scene/Main.tscn")

func _on_Sair_btn_pressed():
	get_tree().quit()
