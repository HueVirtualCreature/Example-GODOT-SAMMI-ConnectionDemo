extends Node

func _ready():
	return;

#If the websocket server receives a message, display it in the log
func _on_server_response(message):
	$VBoxContainer/Log.add_text("\n"+str(message));
	return;
