extends Area2D

export var attack_damage: = 15.0
export var speed = 800

var direction = Vector2.ZERO
var velocity = Vector2.ZERO

var is_lauched = true

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)

func lauching(from, to: Vector2):
	position = from
	velocity = to
	is_lauched = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_lauched:
		position += velocity * speed * delta
		$sprite.rotation = velocity.angle()

func _on_arrow_body_entered(body):
	if not body is KinematicBody2D :
		return
	if body.is_a_parent_of(self):
		return
	body.take_damage(attack_damage)
	queue_free()


func _on_time_out_timeout():
	queue_free()
