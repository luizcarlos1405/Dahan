extends Area2D

onready var sprite = get_node("AnimatedSprite")
onready var animation_player = get_node("AnimationPlayer")

var pode_abrir = false
var aberta     = false
var acabou     = false

func _ready():
	set_process(true)
	set_process_input(true)
	
	# Conectar com callbacks
	connect("body_enter", self, "entrou")
	connect("body_exit", self, "saiu")
	pass

func _process(delta):
	# Se Player estiver na área e apertar o botão abre a porta
	if Input.is_action_pressed("ação") and pode_abrir and not aberta:
		abrir()
	
	if not pode_abrir and aberta == true and acabou:
		fechar()
	pass

func entrou(event):
	if event.get_name() == "Player":
		pode_abrir = true
	pass

func saiu(event):
	if event.get_name() == "Player":
		pode_abrir = false
	pass

func abrir():
	sprite.play("abrir")
	animation_player.play("abrir")
	aberta = true
	acabou = false
	pass

func fechar():
	sprite.play("fechar")
	animation_player.play("fechar")
	aberta = false
	acabou = false
	pass

func acabou_animacao():
	acabou = true
