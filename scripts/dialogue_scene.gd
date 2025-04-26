extends CanvasLayer

var current_dialogue = []
var current_index = 0

var test_dialogue = [
	{
		"character": "安迪",
		"text": "由妳來照顧他吧！",
		"character_image": "res://resources/characters/girl-a-normal.png",
		"background": "res://resources/backgrounds/a-park.png"
	},
	{
		"character": "莉莉",
		"text": "好的，我會好好照顧他的。",
		"character_image": "res://resources/characters/girl-a-surprise.png",
		"background": "res://resources/backgrounds/a-park.png"
	}
]

func _ready():
	current_dialogue = test_dialogue
	current_index = 0
	show_current_dialogue()

func show_current_dialogue():
	if current_index >= len(current_dialogue):
		return
		
	var dialogue = current_dialogue[current_index]
	$UIRoot/DialoguePanel/CharacterName.text = dialogue["character"]
	$UIRoot/DialoguePanel/DialogueText.text = dialogue["text"]
	
	# 如果有角色圖片
	if dialogue.has("character_image"):
		var texture = load(dialogue["character_image"])
		if texture:
			$UIRoot/CharacterSprite.texture = texture
		
	# 如果有背景
	if dialogue.has("background"):
		var texture = load(dialogue["background"])
		if texture:
			$UIRoot/Background.texture = texture

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			next_dialogue()

func next_dialogue():
	current_index += 1
	if current_index < len(current_dialogue):
		show_current_dialogue()
