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
		"text": "這個責任很重大...",
		"character_image": "res://resources/characters/girl-a-sad.png",
		"background": "res://resources/backgrounds/a-park.png",
		"choices": [
			{
				"text": "我會盡力的！",
				"next_dialogue": "accept_route"
			},
			{
				"text": "我需要考慮一下...",
				"next_dialogue": "hesitate_route"
			},
			{
				"text": "這太困難了...",
				"next_dialogue": "reject_route"
			}
		]
	}
]

var dialogue_routes = {
	"accept_route": [
		{
			"character": "莉莉",
			"text": "好！我一定會好好照顧他的！",
			"character_image": "res://resources/characters/girl-a-surprise.png",
			"background": "res://resources/backgrounds/a-park.png"
		},
		{
			"character": "安迪",
			"text": "我相信你一定做得到。",
			"character_image": "res://resources/characters/girl-a-normal.png",
			"background": "res://resources/backgrounds/a-park.png"
		}
	],
	"hesitate_route": [
		{
			"character": "莉莉",
			"text": "這確實需要好好思考...",
			"character_image": "res://resources/characters/girl-a-sad.png",
			"background": "res://resources/backgrounds/a-park.png"
		},
		{
			"character": "安迪",
			"text": "沒關係，慢慢考慮。",
			"character_image": "res://resources/characters/girl-a-normal.png",
			"background": "res://resources/backgrounds/a-park.png"
		}
	],
	"reject_route": [
		{
			"character": "莉莉",
			"text": "對不起，我可能無法勝任...",
			"character_image": "res://resources/characters/girl-a-sad.png",
			"background": "res://resources/backgrounds/a-park.png"
		},
		{
			"character": "安迪",
			"text": "我明白了，這確實是個艱難的決定。",
			"character_image": "res://resources/characters/girl-a-normal.png",
			"background": "res://resources/backgrounds/a-park.png"
		}
	]
}

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
			
	# 如果有選項
	if dialogue.has("choices"):
		show_choices(dialogue["choices"])

func show_choices(choices):
	# 清除現有的選項按鈕
	for child in $UIRoot/ChoicePanel/ChoiceContainer.get_children():
		child.queue_free()
	
	# 創建新的選項按鈕
	for choice in choices:
		var button = Button.new()
		button.text = choice["text"]
		button.custom_minimum_size = Vector2(0, 50)
		button.pressed.connect(_on_choice_selected.bind(choice))
		$UIRoot/ChoicePanel/ChoiceContainer.add_child(button)
	
	# 顯示選項面板
	$UIRoot/ChoicePanel.visible = true

func _on_choice_selected(choice):
	# 隱藏選項面板
	$UIRoot/ChoicePanel.visible = false
	
	# 切換到選擇的對話路線
	if choice.has("next_dialogue") and dialogue_routes.has(choice["next_dialogue"]):
		current_dialogue = dialogue_routes[choice["next_dialogue"]]
		current_index = 0
		show_current_dialogue()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# 如果選項面板可見，不要進行下一段對話
			if not $UIRoot/ChoicePanel.visible:
				next_dialogue()

func next_dialogue():
	current_index += 1
	if current_index < len(current_dialogue):
		show_current_dialogue()
