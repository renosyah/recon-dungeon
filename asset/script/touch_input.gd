extends Node

const MOBILE_DEVICE_OS = ["Android", "iOS"]
const DEKSTOP_DEVICE_OS = ["Windows","X11"]

# broadcast to outside schene signal
signal on_joystick_move(position)
signal on_attack_button_press()
signal on_player_press_reload()
signal on_exit_button_pressed()

func _ready():
	pass

func _on_touchscreen_input_joystick(position):
	emit_signal("on_joystick_move",position)

func _on_exit_button_pressed():
	emit_signal("on_exit_button_pressed")

func _on_attack_button_pressed():
	emit_signal("on_attack_button_press")
 
func _on_player_unit_hit_point_change(hp):
	$v_container/h_top_ui/bar/hit_point.value = hp

func _on_player_unit_on_unit_ready(status_bar_data):
	$v_container/h_top_ui/panel/player_name.text = status_bar_data.player_name
	$v_container/h_top_ui/bar/hit_point.max_value = status_bar_data.max_hit_point
	$v_container/h_top_ui/bar/hit_point.value = status_bar_data.hit_point
	$v_container/h_input_ui/right_input/ammo_left_button.text =  str(status_bar_data.ammo) + "/" + str(status_bar_data.max_ammo)
		
func _on_player_unit_enemy_in_range(is_attackable):
	$v_container/h_input_ui/right_input/attack_button.visible = is_attackable

func _on_player_unit_ammo_change(ammo,max_ammo):
	$v_container/h_input_ui/right_input/ammo_left_button.text =  str(ammo) + "/" + str(max_ammo)
	if ammo <= 0:
		$v_container/h_input_ui/right_input/ammo_left_button.text = "reloading..."

func _on_ammo_left_button_pressed():
	emit_signal("on_player_press_reload")
	$v_container/h_input_ui/right_input/ammo_left_button.text = "reloading..."
