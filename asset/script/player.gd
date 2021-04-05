extends Control

onready var died_message = $canvas/died_message
onready var remote_transform = RemoteTransform2D.new()
onready var player_unit = $player_unit

export(Vector2) var position
export(NodePath) var camera_node = NodePath("../camera")

# public variable
export(String) var player_name = "Alex"
export(float) var attack_damage = 15.0
export(float) var hit_point = 100.0
export(float) var max_hit_point = 100.0
export(float) var stamina_point = 100.0
export(float) var max_stamina_point = 100.0
export(int) var max_target = 1
export(String) var side = "player"
export var texture: Texture = load("res://asset/sprite/blue_knight.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	remote_transform.remote_path = NodePath("../../" + str(camera_node))
	remote_transform.force_update_cache()
	player_unit.add_child(remote_transform)
	player_unit.player_name = player_name
	player_unit.position = position
	player_unit.attack_damage = attack_damage
	player_unit.max_target = max_target
	player_unit.hit_point = hit_point
	player_unit.max_hit_point = max_hit_point
	player_unit.stamina_point = stamina_point
	player_unit.max_stamina_point = max_stamina_point
	player_unit.side = side
	player_unit.texture = texture
	player_unit.update_status_bar()


func _on_player_unit_on_unit_died():
	died_message.visible = true

func _on_touch_input_on_exit_button_pressed():
	get_tree().quit(0)

func _on_player_unit_on_unit_spawn():
	player_unit.position = position
	died_message.visible = false
