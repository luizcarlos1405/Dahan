extends KinematicBody2D

const ACELERACAO = 1000
const DESACELERACAO = 500
const VELOCIDADE_X_MAXIMA = 150
const VELOCIDADE_Y_MAXIMA = 1000
const GRAVIDADE = 1000
const PULO = 350

var direcao_entrada = 0
var direcao = 1
var velocidade_x = 0
var velocidade_y = 0
var movimento = Vector2()
var pode_pular = false
var modificador_gravidade = 3

onready var animated_sprite = get_node("AnimatedSprite")

func _ready():
	set_fixed_process(true)
	pass

func _fixed_process(delta):
	# Recebe intenção de movimento do jogador
	direcao_entrada = 0
	
	if Input.is_action_pressed("ui_right") :
		direcao_entrada += 1
	if Input.is_action_pressed("ui_left") :
		direcao_entrada -= 1
	
	var estado_espaco = get_world_2d().get_direct_space_state()
	
	# Raycast
	var origem = get_pos() + Vector2(-3, 0)
	var fim = get_pos() + Vector2(-3, 9)
	var resultado_esquerda = estado_espaco.intersect_ray(origem, fim, [self])
	
	origem = get_pos() + Vector2(3, 0)
	fim = get_pos() + Vector2(3, 9)
	var resultado_direita = estado_espaco.intersect_ray(origem, fim, [self])
	
	if resultado_direita.empty() and resultado_esquerda.empty():
		pode_pular = false
	else:
		pode_pular = true
	
	# Lógica do pulo
	if Input.is_action_pressed("jump"):
		# Calcula gravidade e aplica à velocidade
		velocidade_y += GRAVIDADE * delta
		if pode_pular:
			velocidade_y = -PULO
	elif velocidade_y < 0:
		velocidade_y += GRAVIDADE * modificador_gravidade * delta
	else:
		velocidade_y += GRAVIDADE * delta
	
	if direcao_entrada != 0:
		# Muda de direção se a velocidade_x for 0
		if velocidade_x <= 0:
			direcao = direcao_entrada
		
		# Acelera na direção que o jogador deseja
		if direcao == direcao_entrada :
			velocidade_x += ACELERACAO * delta
		else:
			velocidade_x -= ACELERACAO * delta * 2
		
	else :
		# Desacelera se nada for pressionado
		velocidade_x -= DESACELERACAO * delta
	
	# Garante valores da velocidade_x
	velocidade_x = clamp(velocidade_x, 0, VELOCIDADE_X_MAXIMA)
	velocidade_y = clamp(velocidade_y, -VELOCIDADE_Y_MAXIMA, VELOCIDADE_Y_MAXIMA)
	
	# Calcula quantidade de movimento
	movimento.x = direcao * velocidade_x * delta
	movimento.y = velocidade_y * delta
	
	var movimento_colisao = move(movimento)
	
	if is_colliding() :
		var normal = get_collision_normal()
		var movimento_final = normal.slide(movimento_colisao)
		
		move(movimento_final)
		
		# Impede aceleração em y enquanto jogador estiver colidindo
		if normal.y != 0 :
			velocidade_y = 0
	pass
	
	# Animação
	if direcao < 0 :
		animated_sprite.set_flip_h(true)
	elif direcao > 0:
		animated_sprite.set_flip_h(false)
	
	if velocidade_y == 0 :
		if velocidade_x > 0:
			animated_sprite.play("andando")
		else:
			animated_sprite.play("parado")
	
	elif velocidade_y < 0:
		animated_sprite.play("pulando")
	elif velocidade_y > 50:
		animated_sprite.play("caindo")
	
	
