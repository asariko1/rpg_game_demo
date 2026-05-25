extends CharacterBody2D


@export var speed = 50
@export var sprint_factor = 2
var input_dir = Vector2.ZERO
var movement_dir = ""
var attack = false
var attack_speed = 4

var enemy_attack_range = false
var enemy_attack_cooldown = true
var player_health = 100
var player_alive = true


func _ready() -> void:
	$AnimatedSprite2D.play("idle_front")
	
func _process(delta: float) -> void:
	move_and_slide()
	player_movement()
	movement_direction()
	player_animation()
	player_attack()
	enemy_attack()
	update_health()
	#current_camera() # aşağıdaki camera ayarını kullanmıyorum
	
	
	if player_health <= 0:
		player_alive = false
		player_health = 0
		print("you died")
		self.queue_free()
	
	
func player():
	pass
	
func player_movement():
	if not attack:
		input_dir = Input.get_vector("left","right","up","down")
		velocity = input_dir * speed
		$AnimatedSprite2D.sprite_frames.set_animation_speed("walk_side", 10) #bu değeri animasyon tabinden de ayarlana bilirdi.
		$AnimatedSprite2D.sprite_frames.set_animation_speed("walk_up", 10)
		$AnimatedSprite2D.sprite_frames.set_animation_speed("walk_down", 10)
		if Input	.is_action_pressed("sprint"):#koşma faktörü
			velocity = input_dir * speed * sprint_factor
			$AnimatedSprite2D.sprite_frames.set_animation_speed("walk_side", 20) #kosma animasyonunu 20 pixel yaparak hızlandırdık bacakları.
			$AnimatedSprite2D.sprite_frames.set_animation_speed("walk_up", 20)
			$AnimatedSprite2D.sprite_frames.set_animation_speed("walk_down", 20)
			
func movement_direction():
	if Input	.is_action_pressed("left"):
		movement_dir = "left"
	if Input	.is_action_pressed("right"):
		movement_dir = "right"	
	if Input	.is_action_pressed("up"):
		movement_dir = "up"
	if Input	.is_action_pressed("down"):
		movement_dir = "down"
	
	
func player_animation():
	if not attack:
		
		if velocity:
			if movement_dir == "left":
				$AnimatedSprite2D.play("walk_side")
				$AnimatedSprite2D.flip_h = true
			elif movement_dir == "right":
				$AnimatedSprite2D.play("walk_side")
				$AnimatedSprite2D.flip_h = false	
			elif movement_dir == "up":
				$AnimatedSprite2D.play("walk_up")
				$AnimatedSprite2D.flip_h = false		
			elif movement_dir == "down":
				$AnimatedSprite2D.play("walk_down")
				$AnimatedSprite2D.flip_h = false			
		else:
			if movement_dir == "left":
				$AnimatedSprite2D.play("idle_side")
				$AnimatedSprite2D.flip_h = true
			elif movement_dir == "right":
				$AnimatedSprite2D.play("idle_side")
				$AnimatedSprite2D.flip_h = false	
			elif movement_dir == "up":
				$AnimatedSprite2D.play("idle_back")
				$AnimatedSprite2D.flip_h = false		
			elif movement_dir == "down":
				$AnimatedSprite2D.play("idle_front")
				$AnimatedSprite2D.flip_h = false			
		
func player_attack():
	if Input	.is_action_just_pressed("attack") and not attack:
		global.player_current_attack = true #dşman bizim vurduğumuzu algılıyor
		velocity = Vector2.ZERO
		attack = true
		attack_speed += 1 #atak hızının çarpanı, ileride upgrade alması için
		$Timer.stop() #burası ek olarak atak speedi arttırmak için.
		$Timer.wait_time = 4.0 / attack_speed #float yani ondalıklı sayı olmak zorunda. şu anda her atak bir çncekinden daha hızlı oluyor. +1 frame ekleniyor ve animasyon beklemesi düşüuor.
		#print(attack_speed) #terminalde çalıştığını görek için
		#print($Timer.wait_time)#terminalde çalıştığını görek için
		$Timer.start()
		if movement_dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("attack_side")
		elif movement_dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("attack_side")	
		elif movement_dir == "up":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("attack_up")	
		elif movement_dir == "down":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("attack_front")	



			
func enemy_attack():
	if enemy_attack_range and enemy_attack_cooldown:
		player_health = player_health - 10
		enemy_attack_cooldown = false
		$attack_cooldown.start()

func update_health():
	var healthbar = 	$HealthBar	
	healthbar.value = player_health
	
	if player_health >= 100:
		healthbar.visible = false
	else:	
		healthbar.visible = true


func _on_timer_timeout() -> void:
	attack = false
	$AnimatedSprite2D.sprite_frames.set_animation_speed("attack_side", attack_speed) #atak animasyonunu hızlandırmaakları.
	$AnimatedSprite2D.sprite_frames.set_animation_speed("attack_up", attack_speed)
	$AnimatedSprite2D.sprite_frames.set_animation_speed("walk_down", attack_speed)	
			
			

	


func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_attack_range = true #enemi range girdiğinde damage koyabilecek


func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_attack_range = false 


#bu sahnelerde farklı kamera ayarı için
#func current_camera():
	#if global.current_scene == "world":
		#$Camera_world.enabled = true
		#$Camera_camp.enabled = false
	#elif global.current_scene == "camp":
		#$Camera_world.enabled = false
		#$Camera_camp.enabled = true
			

			
#func player_movement():
	#if Input.is_action_pressed("up")	:
		#velocity.y = - speed
		#velocity.x = 0
	#if Input.is_action_pressed("down")	:
		#velocity.y = speed
		#velocity.x = 0	
	#if Input.is_action_pressed("left")	:
		#velocity.y = 0
		#velocity.x = - speed	
	#if Input.is_action_pressed("right")	:
		#velocity.y = 0
		#velocity.x = speed	


func _on_attack_cooldown_timeout() -> void:
	$attack_cooldown.stop()#sürekli loop yapmasın die her enemy atak sonrası top ettik
	enemy_attack_cooldown = true #timer bitince cool downı yine calıştırdık

#enemy damage yemesi
