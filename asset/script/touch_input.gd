extends Node

const MOBILE_DEVICE_OS = ["Android", "iOS"]
const DEKSTOP_DEVICE_OS = ["Windows","X11"]

# broadcast to outside schene signal
signal on_joystick_move(position)
signal on_attack_button_press()
signal on_exit_button_pressed()
signal on_throw_button_press()

func _ready():
	if DEKSTOP_DEVICE_OS.has(OS.get_name()):
		$v_container/h_input_ui/left_input.visible = false
		$v_container/h_input_ui/right_input.visible = false

func _on_touchscreen_input_joystick(position):
	emit_signal("on_joystick_move",position)

func _on_exit_button_pressed():
	emit_signal("on_exit_button_pressed")

func _on_attack_button_pressed():
	emit_signal("on_attack_button_press")

func _on_throw_button_pressed():
	emit_signal("on_throw_button_press")

func _on_player_unit_hit_point_change(hp):
	$v_container/h_top_ui/bar/hit_point.value = hp

func _on_player_unit_stamina_point_change(stamina):
	$v_container/h_top_ui/bar/stamina_point.value = stamina

func _on_player_unit_on_unit_ready(status_bar_data):
	$v_container/h_top_ui/panel/player_name.text = status_bar_data.player_name
	$v_container/h_top_ui/bar/hit_point.max_value = status_bar_data.max_hit_point
	$v_container/h_top_ui/bar/stamina_point.max_value = status_bar_data.max_stamina_point
	$v_container/h_top_ui/bar/hit_point.value = status_bar_data.hit_point
	$v_container/h_top_ui/bar/stamina_point.value = status_bar_data.stamina_point
		
func _on_player_unit_enemy_in_range(is_attackable):
	$v_container/h_input_ui/right_input/attack_button.visible = is_attackable

