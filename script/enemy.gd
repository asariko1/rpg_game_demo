extends CharacterBody2D

var speed = 50
var player_chase = false
var player = null


func _ready() -> void:
	player_chase = false
	$AnimatedSprite2D.play("idle_front")


func _physics_process(delta: float) -> void:
	if player_chase:
		print("player chase")
		position += (player.position - position) / 50 #movementı bu hesaplıyor, playerın enemıye olan pozisyonunu alıp o yone 50 hızla ilerliyor
		$AnimatedSprite2D.play("walk_side")
		if (player.position.x - position.x) < 0:  #player pozisyonu eksi enemi pozisyonu 0 dan küşükse suratı yön değiştirsin
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false	
	else: 
		print("idle"	)	
		$AnimatedSprite2D.play("idle_front") #kovalamaca biterse idle pozisyona dönüş
	move_and_slide()	

func enemy():#bu boş kalacak. detect edilen body nin enemy olup olmadığını diyer kodlarda anlayabileceğiz
	pass

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"): #bu satır eneminin kendi alanını detect etmemesi için, sadece player girdiğinde aktif olması için
		player = body
		player_chase = true
	
	



func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"): #bu satır eneminin kendi alanını detect etmemesi için, sadece player girdiğinde aktif olması için
		player = null
		player_chase = false
