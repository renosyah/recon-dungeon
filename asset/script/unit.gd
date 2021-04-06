extends KinematicBody2D

# const
const killed_sound = [
		preload("res://asset/sound/maledeath3.wav"),
		preload("res://asset/sound/maledeath4.wav")

]
const combats_sound = [
	preload("res://asset/sound/stab1.wav"),
	preload("res://asset/sound/stab2.wav"),
	preload("res://asset/sound/stab3.wav")
]

# signal


# mutable variable
var is_dead = false
var target: KinematicBody2D = null
var velocity = Vector2.ZERO

# onready variable
onready var rng = RandomNumberGenerator.new()
onready var detection_area = $detection_area
onready var sprite = $sprite
onready var attack_delay = $attack_delay
onready var targeting_sprite = $targeting_sprite
onready var range_attack_delay = $range_attack_delay
onready var audio = $audio
onready var animation = $animation
onready var animation_tree = $animation_tree
onready var animation_state = animation_tree.get("parameters/playback")

# public variable
export var attack_damage: = 15.0
export var hit_point: = 100.0 setget _set_hit_point
export var max_hit_point: = 100.0
export var max_speed: = 250
export var friction : = 500
export var attack_distance: = 80.0
export var min_to_attack_distance: = 200.0
export var max_to_attack_distance: = 400.0
export var attack_delay_value: = 1.0
export var side = "bandit"
export var texture: Texture = preload("res://asset/sprite/red_knight.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	$hit_point.max_value = max_hit_point
	sprite.texture = texture
	attack_delay.wait_time = attack_delay_value
	set_physics_process(true)

func _physics_process(delta):
	if is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		var distance_to_target = global_position.distance_to(target.global_position)
		sprite.flip_h = direction.x < 0
	
		if distance_to_target >= min_to_attack_distance and distance_to_target < max_to_attack_distance:
			animation_state.travel("character_walking")
			velocity = direction * max_speed * delta
			move_and_collide(velocity)

		if range_attack_delay.is_stopped() and distance_to_target > min_to_attack_distance:
			animation_state.travel("character_attack")
			shoot_spear(direction)
			range_attack_delay.start()

		if attack_delay.is_stopped() and distance_to_target <= min_to_attack_distance:
			animation_state.travel("character_attack")
			target.take_damage(attack_damage)
			attack_delay.start()
		
	else:
		animation_state.travel("character_idle")
		

#########################################################
# spawn spear
func shoot_spear(dir):
	var spear = preload("res://asset/scene/arrow.tscn").instance()
	spear.attack_damage = attack_damage
	spear.lauching(position, dir)
	add_child(spear)


#########################################################
# unit hit point
func take_damage(damage):
	play_hit_sound()
	self.hit_point -= damage
	if self.hit_point <= 0:
		set_physics_process(false)
		target = null
		is_dead = true
		play_dead_sound()
		

func _set_hit_point(hp):
	hit_point = max(0,hp)
	$hit_point.value = hit_point
	

#########################################################
# unit hit dead sanimation end
func _on_dead_animation_end():
	queue_free()
	

#########################################################
# unit hit and dead sound
func play_dead_sound():
	audio.stream = killed_sound[rng.randf_range(0,killed_sound.size())]
	audio.play()
	animation_state.travel("character_dead")

func play_hit_sound():
	if audio.playing:
		return
	audio.stream = combats_sound[rng.randf_range(0,combats_sound.size())]
	audio.play()
	
#########################################################
# on enemy enter attack area of player unit
func _on_detection_area_body_entered(body):
	if  !is_dead and body is KinematicBody2D and body.side != side:
		target = body

# on enemy exit attack area of player unit
func _on_detection_area_body_exited(_body):
	if _body is KinematicBody2D and !is_dead:
		var distance_to_target = global_position.distance_to(_body.global_position)
		if distance_to_target < min_to_attack_distance:
			target = null
			animation_state.travel("character_idle")


#########################################################
# reset detection each 1 second
func _on_timer_reset_target_timeout():
#	detection_area.monitoring = false
#	detection_area.monitoring = true
	pass
	
