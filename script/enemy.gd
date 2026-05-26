extends CharacterBody2D
# Variables
var speed = 50
var player_chase = false
var vector_chase = Vector2.ZERO
var player = null
var random_dir = Vector2.ZERO
var idle = true
var idle_speed = 20
var idle_walking = false
var idle_stop =false

var enemy_alive = true
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
	chasing_player()
	chasing_animation()
	
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
	if enemy_alive:
		if idle == true and idle_stop == false:
			velocity = random_dir * idle_speed
		else:	
			velocity = Vector2.ZERO
#------------------------------------------------------------------------

#Player Chase
func chasing_player():
	if player_chase and enemy_alive:
		var distance = position.distance_to(player.position)
		if distance > 12:
			vector_chase = (player.position - position).normalized()
			velocity = vector_chase * speed / 2 # ben bçlü 2 yaptım cok suratlıydı
#------------------------------------------------------------------------

# Damage
func deal_with_damage():
	if enemy_alive == true:
		if global.player_current_attack and enemy_hitbox:
			if can_take_damage:
				can_take_damage = false
				$damage_cooldown.start()
				enemy_health = enemy_health - 35
				print(enemy_health)
				if enemy_health <= 0:
					velocity = Vector2.ZERO #death animasyonu kayarak gidiyordu hızı sıf yaptık
					$AnimatedSprite2D.play("death")
					$timer_death.start()
					enemy_alive = false
					


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
	if player_chase == false and enemy_alive: #bu satır idle ve chase animasyonunn aynı anda çalışmasını önlüuor
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
			
			
func chasing_animation():
	if player_chase == true and enemy_alive:
		if abs(vector_chase.x) > abs(vector_chase.y): #bu satır bıze horızontal mı yoksa vertıcal mı yoneldiğimizi gösteriyor
			if $AnimatedSprite2D.animation != "walk_side": #bu satır, animasyon zaten play etmiyorsa bu animasyon oynasın diyor (that prevents restarting every frame)
				$AnimatedSprite2D.play("walk_side")
				if vector_chase.x < 0: #sola mı sağa mı yürüyoruz
					$AnimatedSprite2D.flip_h = true
				else:
					$AnimatedSprite2D.flip_h = false		
		elif abs(vector_chase.x) < abs(vector_chase.y):	
			if vector_chase.y > 0: # yukarı mı aşağı mı yürüyoruz
				if $AnimatedSprite2D.animation != "walk_front":
					$AnimatedSprite2D.play("walk_front")
			else:
				if $AnimatedSprite2D.animation != "walk_back":
					$AnimatedSprite2D.play("walk_back")


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


func _on_timer_death_timeout() -> void:
	self.queue_free()
	
	
#------------------------------------------------------------------------	
