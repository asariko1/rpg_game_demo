extends CharacterBody2D
# Variables
var speed = 50
var player_chase = false
var player = null
var random_dir = Vector2.ZERO
var idle = true
var idle_speed = 20
var idle_walking = false
var idle_stop =false

var enemy_health = 100
var enemy_hitbox = false
var can_take_damage = true
#------------------------------------------------------------------------
# BAsic Functions
func _ready() -> void:
	player_chase = false
	$AnimatedSprite2D.play("idle_front")


func _physics_process(delta: float) -> void:
	deal_with_damage()
	move_and_slide()	
	random_direction()
	idle_walk()
	idle_animation()
	
	
	if player_chase:
		#print("player chase")
		position += (player.position - position) / 50 #movementı bu hesaplıyor, playerın enemıye olan pozisyonunu alıp o yone 50 hızla ilerliyor
		




func enemy():#bu boş kalacak. detect edilen body nin enemy olup olmadığını diyer kodlarda anlayabileceğiz
	pass

#------------------------------------------------------------------------



# Idle Walk
func random_direction():
	
	if idle == true and idle_walking == false:
		var random_waiting = randf_range(1, 3)
		$timer_direction.wait_time = random_waiting + randf_range(1, 3)
		$timer_walk.wait_time = random_waiting
		$timer_direction.start()
		$timer_walk.start()
		random_dir = Vector2(randf_range(-10, 10), randf_range(-10, 10)).normalized() #random yürüyüş hem x hem y değeri
		idle_walking = true
		idle_stop = false
		
		
func idle_walk():
	if idle == true and idle_stop == false:
		velocity = random_dir * idle_speed
	else:	
		velocity = Vector2.ZERO
#------------------------------------------------------------------------

#Player Chase
func chasing_player():
	if player_chase:
			position += (player.position - position) / speed

#------------------------------------------------------------------------

# Damage
func deal_with_damage():
	if global.player_current_attack and enemy_hitbox:
		if can_take_damage:
			can_take_damage = false
			$damage_cooldown.start()
			enemy_health = enemy_health - 35
			print(enemy_health)
			if enemy_health <= 0:
				self.queue_free()


#Timer
func _on_damage_cooldown_timeout() -> void:
	$damage_cooldown.stop()
	can_take_damage = true
	
func _on_timer_direction_timeout() -> void:
	idle_walking = false

func _on_timer_walk_timeout() -> void:
	idle_stop = true
#------------------------------------------------------------------------

# Animation
func idle_animation():
	if abs(random_dir.x) > abs(random_dir.y):
		$AnimatedSprite2D.play("idle_side")
		if random_dir.x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false	
	if abs(random_dir.y) > abs(random_dir.x):	
		if random_dir.y < 0:
			$AnimatedSprite2D.play("idle_back")
		else: 
			$AnimatedSprite2D.play("idle_front")
	


#------------------------------------------------------------------------

#Signals
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"): #bu satır eneminin kendi alanını detect etmemesi için, sadece player girdiğinde aktif olması için
		player = body
		player_chase = true
	

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"): #bu satır eneminin kendi alanını detect etmemesi için, sadece player girdiğinde aktif olması için
		player = null
		player_chase = false


func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		enemy_hitbox = true


func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		enemy_hitbox = false
#------------------------------------------------------------------------
