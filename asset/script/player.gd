extends Control

onready var canvas = $canvas
onready var died_message = $canvas/died_message
onready var remote_transform = RemoteTransform2D.new()
onready var player_unit = $player_unit

export(Vector2) var position
export(NodePath) var camera_node = NodePath("../camera")

# Called when the node enters the scene tree for the first time.
func _ready():
	remote_transform.remote_path = NodePath("../../" + str(camera_node))
	remote_transform.force_update_cache()
	player_unit.add_child(remote_transform)
	player_unit.position = position
	player_unit.player_name = "Alex"
	player_unit.attack_damage = 12.0
	player_unit.attack_delay = 0.2
	player_unit.reload_delay = 2.5
	player_unit.hit_point = 100.0
	player_unit.max_hit_point = 100.0
	player_unit.hit_point_regeneration = 0.8
	player_unit.ammo = 100
	player_unit.spread = 0.2
	player_unit.max_ammo = 100
	player_unit.max_speed  = 250
	player_unit.max_target = 1
	player_unit.side = "player"
	player_unit.texture = load("res://asset/sprite/blue_knight.png")
	player_unit.update_status_bar()

func _on_player_unit_on_unit_died():
	died_message.visible = true

func _on_player_unit_on_unit_spawn():
	player_unit.position = position
	died_message.visible = false
