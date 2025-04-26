extends CanvasLayer

var current_dialogue = []
var current_index = 0

var test_dialogue = [
	{
		"character": "莉莉",
		"text": "哈囉～好久不見！你也來公園散步嗎？",
		"character_image": "res://resources/characters/girl-a-normal.png",
		"background": "res://resources/backgrounds/a-park.png"
	},
	{
		"character": "我",
		"text": "嗨，好久不見⋯⋯",
		"character_image": "res://resources/characters/girl-a-normal.png",
		"background": "res://resources/backgrounds/a-park.png",
		"choices": [
			{
				"text": "我來溜狗啦",
				"next_dialogue": "dog_route"
			},
			{
				"text": "對啊，最近心情不好，來散散心",
				"next_dialogue": "feeling_route"
			},
			{
				"text": "對啊，我想說可能會遇見你。",
				"next_dialogue": "reject_route"
			}
		]
	}
]

var dialogue_routes = {
	"dog_route": [
		{
			"character": "莉莉",
			"text": "哇！好可愛的狗狗！你養多久了啊？",
			"character_image": "res://resources/characters/girl-a-surprise.png",
			"background": "res://resources/backgrounds/a-park.png"
		},
		{
			"character": "我",
			"text": "其實才養了兩個月而已。",
			"character_image": "res://resources/characters/girl-a-surprise.png",
			"background": "res://resources/backgrounds/a-park.png"
		}
	],
	"feeling_route": [
		{
			"character": "莉莉",
			"text": "你最近怎麼嗎？還好嗎？",
			"character_image": "res://resources/characters/girl-a-surprise.png",
			"background": "res://resources/backgrounds/a-park.png"
		},
		{
			"character": "我",
			"text": "喔，沒什麼啦，只是最近比較忙，所以有點累。",
			"character_image": "res://resources/characters/girl-a-surprise.png",
			"background": "res://resources/backgrounds/a-park.png"
		}
	],
	"reject_route": [
		{
			"character": "莉莉",
			"text": "⋯⋯你怎麼知道我會在公園，你是變態嗎？",
			"character_image": "res://resources/characters/girl-a-angry.png",
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
