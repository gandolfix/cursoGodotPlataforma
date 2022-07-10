extends KinematicBody2D

const GRAVIDADE = 4000
var velocidade = Vector2(0,0)
var velMax = 420
var jumpForce = 1200
var jumpCount = 2
var wasFalling = false

#camera
var marterRoom = false
var zoom = 1.5

#camera offset
var offset_cam = 0
var offset_max_value = 250

func _ready():
	$cam.limit_left = $"../pos_inicial".position.x
	$cam.limit_right = $"../pos_final".position.x
	
func _process(delta):
	#Aplicação da Gravidade
	velocidade.y += GRAVIDADE * delta
		
	if marterRoom:
		zoom = lerp(zoom, 2.5, 0.05)
	else:
		zoom = lerp(zoom, 1.5, 0.05)		
		
	$cam.zoom = Vector2(zoom,zoom)
	
	#definindo a direção do player
	var dir = Input.get_axis("left","right")
	#velocidade.x = dir * velMax
	
	#aceleração do player
	if dir != 0:
		velocidade.x = lerp(velocidade.x, dir * velMax, 0.05)
	else:
		if is_on_floor():
			velocidade.x = lerp(velocidade.x, 0, 0.2)
		else:
			velocidade.x = lerp(velocidade.x, 0, 0.01)
			
	#camera offset
	if dir != 0:
		if $sprite.flip_h: #olhando para a direita
			offset_cam = lerp(offset_cam, offset_max_value, 0.03)
		else:	#olhando para a esquerda
			offset_cam = lerp(offset_cam, -offset_max_value, 0.03)
	$cam.offset.x = offset_cam
	
	#personagem pulando
	if is_on_floor():
		$sombra.visible = true
		jumpCount = 2
		
		#para onde olha o player
		if dir < 0:
			$sprite.flip_h = false
			
		if dir > 0:
			$sprite.flip_h = true
			
		if wasFalling:
			$anim.play("jump3")
		else:
			#animação do player
			if dir != 0:
				$anim.play("running")
			else:
				$anim.play("idle")
	
	if Input.is_action_just_pressed("jump"):
		jump()
		
	if is_on_floor() and dir !=0:
		$smoke.emitting = true
	else:
		$smoke.emitting = false
	
	# Movimentação
	velocidade = move_and_slide(velocidade, Vector2.UP, true)
	
	
func jump():
	$sombra.visible = false
	if jumpCount > 0:
		$anim.play("jump1")
		jumpCount -= 1
		velocidade.y = -jumpForce

func jump2():
	wasFalling = true
	$anim.play("jump2")
	
func resetFalling():
	wasFalling = false

func _on_limit_left_body_entered(body):
	if body.name == "player":
		$cam.limit_left = $"../pos_inicial_boss".position.x
		marterRoom = true
