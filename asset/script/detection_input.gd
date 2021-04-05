extends Area2D

var all_visible = false

func _ready():
	pass


func _process(_delta):
	$joystick.visible = all_visible


func _input(_event):
	get_viewport().unhandled_input( _event)


func _input_event(_viewport, _event, _shape_idx):
	all_visible = _event is InputEventScreenDrag or (_event is InputEventScreenTouch and _event.is_pressed())
	if _event is InputEventScreenTouch and  _event.is_pressed():
		$joystick.position = _event.position

