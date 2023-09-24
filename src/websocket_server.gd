extends Node

var server = TCPServer.new()

#The port we will connect to. Change this if you want
var PORT = 8001

#Since this is a server, we may have many connections. Each time we get a new connection, we put it in this array
var connected_clients = []

#Used to signal and display messages to the log, when we receive them
signal message(response)

func _ready():
	message.emit("Starting Websocket server");
	#Start server
	var result = server.listen(PORT, "*")
	
	#Report on the server status
	if result == OK:
		message.emit("WebSocket server listening on port " + str(PORT))
	else:
		message.emit("Failed to bind WebSocket server to port " + str(PORT))
		return

func _process(_delta):
	#Only do stuff if the server is running and listening
	if (server.is_listening() == false): return;
	
	#Is there a new connection?
	var potential_connection = server.is_connection_available()
	if (potential_connection == true):
		#There is a new connection available!
		var stream = server.take_connection()
		if stream != null:
			message.emit("Connection found! Adding to client collection")
			stream.set_no_delay(true)
			#Convert the connection into a websocketpeer, which is what can actually accept packets
			var socket = WebSocketPeer.new();
			socket.accept_stream(stream);
			#Add the connection to our list of connections
			connected_clients.append(socket)
	
	#For each connection client, poll and see if there is a message
	for client in connected_clients:
		client.poll();
		var response_available = client.get_available_packet_count()
		if (response_available > 0):
			#There is a new message from this client
			var response = client.get_packet().get_string_from_utf8();
			#Display the message
			message.emit(response);
		
		
