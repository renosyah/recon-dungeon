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
const target_sprite_empty = preload("res://asset/sprite/empty_target.png")
const target_sprite_range = preload("res://asset/sprite/target.png")
const target_sprite_melee = preload("res://asset/sprite/target_sword.png")

enum {
	MOVE,
	ATTACK
}

 # signal
signal on_unit_ready(status_bar_data)
signal hit_point_change(hp)
signal stamina_point_change(stamina)
signal on_unit_died()
signal on_unit_spawn()

# mutable variable
var joystick_velocity = Vector2.ZERO
var velocity = Vector2.ZERO
var targets: = []
var range_targets: = []
var state = MOVE

# onready variable
onready var rng = RandomNumberGenerator.new()
onready var collision = $collision
onready var sprite = $sprite
onready var targeting_sprite = $targeting_sprite
onready var animation = $animation
onready var animation_tree = $animation_tree
onready var animation_state = animation_tree.get("parameters/playback")
onready var audio = $audio
onready var hit_point_bar = $hit_point
onready var player_name_label = $player_name
onready var respawn_timer = $respawn_timer
onready var attack_area = $attack_area
onready var attack_range_area = $attack_range_area
onready var died_message = $".."/canvas/died_message
	
# public variable
export var player_name = ""
export var attack_damage: = 15.0
export var hit_point: = 100.0 setget _set_hit_point
export var max_hit_point: = 100.0
export var stamina_point: = 100.0 setget _set_stamina_point
export var max_stamina_point: = 100.0
export var max_speed: = 250
export var friction : = 500
export var max_target: = 1
export var side = "1"
export var texture: Texture


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	match state:
		MOVE:
			move_unit(_delta)
		ATTACK:
			attack(_delta)

#########################################################
# unit move state and animation
func update_status_bar():
	emit_signal("on_unit_ready",{ 
		"player_name" : player_name,
		"hit_point" : hit_point,
		"max_hit_point" : max_hit_point,
		"stamina_point" : stamina_point,
		"max_stamina_point" : max_stamina_point
	})
	hit_point_bar.visible = false
	player_name_label.text = player_name
	player_name_label.visible = false
	targeting_sprite.visible = false
	sprite.texture = texture
	set_physics_process(true)

#########################################################
# unit move state and animation
func move_unit(_delta):
	var motion = Vector2.ZERO
	motion.x = joystick_velocity.x
	motion.y = joystick_velocity.y
	
	if joystick_velocity == Vector2.ZERO:
		motion.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		motion.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		
	motion.normalized()
	
	if motion != Vector2.ZERO:
		animation_state.travel("character_walking")
		velocity = motion * max_speed
	else:
		animation_state.travel("character_idle")
		velocity = motion.move_toward(Vector2.ZERO * max_speed, friction * _delta)
	
	move_and_slide(velocity)


#########################################################
# unit attack state and animation
func attack(_delta):
	animation_state.travel("character_attack")

func _on_attack_animation_end():
	state = MOVE


#########################################################
# unit hit animation functions
func play_dead_animation():
	animation_state.travel("character_dead")
	
func _on_dead_animation_end():
	start_respawn_time()

#########################################################
# unit input control from user
func _on_touch_input_on_joystick_move(position):
	joystick_velocity = position
	
func _on_touch_input_on_attack_button_press():
	swing_sword()
	
func _input(event):
	if event.is_action_pressed("attack"):
		swing_sword()
	elif event.is_action_pressed("throw_spear"):
		throw_spear()
		
func _on_touch_input_on_throw_button_press():
	throw_spear()
	
#########################################################
# spawn spear for range attack 
func throw_spear():
	var required_stamina = attack_damage
	if self.stamina_point - required_stamina <= 0.0 || range_targets.size() == 0:
		return
	for range_target in range_targets:
		self.stamina_point -= required_stamina
		var direction = (range_target.global_position - global_position).normalized()
		var spear = preload("res://asset/scene/arrow.tscn").instance()
		spear.attack_damage = attack_damage / 2
		spear.lauching(global_position, direction)
		add_child(spear)
	
# slash with sword for close attack
func swing_sword():
	var required_stamina = attack_damage
	if self.stamina_point - required_stamina <= 0.0 || targets.size() == 0:
		return
	state = ATTACK
	for target in targets:
		self.stamina_point -= required_stamina
		target.take_damage(attack_damage)

#########################################################
# unit hit sound functions
func play_dead_sound():
	audio.stream = killed_sound[rng.randf_range(0,killed_sound.size())]
	audio.disconnect("finished",self,"_on_dead_sound_end")
	audio.connect("finished",self,"_on_dead_sound_end")
	audio.play()
	
func _on_dead_sound_end():
	audio.disconnect("finished",self,"_on_dead_sound_end")
	set_physics_process(false)
	play_dead_animation()
	
func play_hit_sound():
	audio.stream = combats_sound[rng.randf_range(0,combats_sound.size())]
	audio.play()


#########################################################
# unit hit point and stamina functions
func take_damage(damage):
	play_hit_sound()
	self.hit_point -= damage
	if self.hit_point <= 0.0:
		play_dead_sound()

	
func _set_hit_point(hp):
	hit_point = max(0, hp)
	hit_point_bar.value = hit_point
	emit_signal("hit_point_change",hit_point)


func _set_stamina_point(sp):
	stamina_point = max(0, sp)
	emit_signal("stamina_point_change", stamina_point)
	

func _on_stamina_regeneration_time_timeout():
	if self.stamina_point < max_stamina_point:
		self.stamina_point += (max_stamina_point * 10.0) / 100.0

#########################################################
# on enemy enter attack area of player unit
func _on_attack_area_body_entered(_body):
	if _body is KinematicBody2D and _body.side != side:
		if targets.size() >= max_target:
			return
		targets.append(_body)
		for target in targets:
			target.targeting_sprite.texture = target_sprite_melee

# on enemy exit attack area of player unit
func _on_attack_area_body_exited(_body):
	if _body is KinematicBody2D and _body.side != side:
		_body.targeting_sprite.texture = target_sprite_empty
	targets.erase(_body)


func _on_attack_range_area_body_entered(_body):
	if _body is KinematicBody2D and _body.side != side:
		if range_targets.size() >= max_target:
			return
		range_targets.append(_body)
		for range_target in range_targets:
			range_target.targeting_sprite.texture = target_sprite_range

func _on_attack_range_area_body_exited(_body):
	if _body is KinematicBody2D and _body.side != side:
		_body.targeting_sprite.texture = target_sprite_empty
	range_targets.erase(_body)

#########################################################
# respawn
func start_respawn_time():
	emit_signal("on_unit_died")
	died_message.visible = true
	respawn_timer.wait_time = 5
	respawn_timer.start()
	targets.clear()
	range_targets.clear()
	attack_area.monitoring = false
	attack_range_area.monitoring = false
	set_physics_process(false)
	for child in get_children():
		if child.has_method('hide'):
			child.hide()
	collision.disabled = true

func _on_respawn_timer_timeout():
	died_message.visible = false
	respawn_timer.stop()
	set_physics_process(true)
	attack_area.monitoring = true
	attack_range_area.monitoring = true
	for child in get_children():
		if child.has_method('show'):
			child.show()
	collision.disabled = false
	self.hit_point = max_hit_point
	self.stamina_point = max_stamina_point
	update_status_bar()
	emit_signal("on_unit_spawn")

