extends CharacterBody2D

var speed = 50
var player_chase = false
var player = null
var enemy_health = 100

var enemy_hitbox = false
var can_take_damage = true


func _ready() -> void:
	player_chase = false
	$AnimatedSprite2D.play("idle_front")


func _physics_process(delta: float) -> void:
	deal_with_damage()
	
	if player_chase:
		#print("player chase")
		position += (player.position - position) / 50 #movementı bu hesaplıyor, playerın enemıye olan pozisyonunu alıp o yone 50 hızla ilerliyor
		$AnimatedSprite2D.play("walk_side")
		if (player.position.x - position.x) < 0:  #player pozisyonu eksi enemi pozisyonu 0 dan küşükse suratı yön değiştirsin
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false	
	else: 
		#print("idle"	)	
		$AnimatedSprite2D.play("idle_front") #kovalamaca biterse idle pozisyona dönüş
	move_and_slide()	




func enemy():#bu boş kalacak. detect edilen body nin enemy olup olmadığını diyer kodlarda anlayabileceğiz
	pass


func deal_with_damage():
	if global.player_current_attack and enemy_hitbox:
		if can_take_damage:
			can_take_damage = false
			$damage_cooldown.start()
			enemy_health = enemy_health - 35
			print(enemy_health)
			if enemy_health <= 0:
				self.queue_free()

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


func _on_damage_cooldown_timeout() -> void:
	$damage_cooldown.stop()
	can_take_damage = true
