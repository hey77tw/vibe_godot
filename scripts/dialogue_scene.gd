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
				"next_dialogue": "dog_route_1"
			},
			{
				"text": "對啊，最近心情不好，來散散心",
				"next_dialogue": "feeling_route_1"
			},
			{
				"text": "對啊，我想說可能會遇見你。",
				"next_dialogue": "stalker_route_1"
			}
		]
	}
]

var dialogue_routes = {
	"dog_route_1": [
		{
			"character": "莉莉",
			"text": "哇！好可愛的狗狗！你養多久了啊？",
			"character_image": "res://resources/characters/girl-a-surprise.png",
			"background": "res://resources/backgrounds/a-park.png"
		},
		{
			"character": "我",
			"text": "其實才養了兩個月而已。",
			"character_image": "res://resources/characters/girl-a-normal.png",
			"background": "res://resources/backgrounds/a-park.png"
		},
		{
			"character": "莉莉",
			"text": "可以讓我摸摸牠嗎？",
			"character_image": "res://resources/characters/girl-a-normal.png",
			"background": "res://resources/backgrounds/a-park.png",
			"choices": [
				{
					"text": "當然可以！牠很親人的",
					"next_dialogue": "dog_route_2a"
				},
				{
					"text": "抱歉，牠有點怕生...",
					"next_dialogue": "dog_route_2b"
				}
			]
		}
	],
	"dog_route_2a": [
		{
			"character": "莉莉",
			"text": "真的好可愛！而且好乖喔～",
			"character_image": "res://resources/characters/girl-a-surprise.png",
			"background": "res://resources/backgrounds/a-park.png"
		},
		{
			"character": "我",
			"text": "對啊，牠很喜歡你呢！",
			"character_image": "res://resources/characters/girl-a-normal.png",
			"background": "res://resources/backgrounds/a-park.png"
		},
		{
			"character": "莉莉",
			"text": "我也很喜歡狗狗！我們要不要一起散步？",
			"character_image": "res://resources/characters/girl-a-normal.png",
			"background": "res://resources/backgrounds/a-park.png",
			"choices": [
				{
					"text": "好啊，一起走吧！",
					"next_dialogue": "dog_happy_end"
				}
			]
		}
	],
	"dog_route_2b": [
		{
			"character": "莉莉",
			"text": "這樣啊...那我們改天再約吧！",
			"character_image": "res://resources/characters/girl-a-sad.png",
			"background": "res://resources/backgrounds/a-park.png",
			"choices": [
				{
					"text": "好，改天見！",
					"next_dialogue": "feeling_route_2"
				}
			]
		}
	],
	"dog_happy_end": [
		{
			"is_ending": true,
			"ending_text": "狗狗結局：你們一起散步，成為了好朋友。",
			"background": "res://resources/endings/ending-dog.png"
		}
	],
	"feeling_route_1": [
		{
			"character": "莉莉",
			"text": "你最近怎麼了？還好嗎？",
			"character_image": "res://resources/characters/girl-a-surprise.png",
			"background": "res://resources/backgrounds/a-park.png"
		},
		{
			"character": "我",
			"text": "喔，沒什麼啦...",
			"character_image": "res://resources/characters/girl-a-normal.png",
			"background": "res://resources/backgrounds/a-park.png",
			"choices": [
				{
					"text": "只是工作有點累...",
					"next_dialogue": "feeling_route_2"
				},
				{
					"text": "其實是感情問題...",
					"next_dialogue": "feeling_route_3"
				}
			]
		}
	],
	"feeling_route_2": [
		{
			"character": "莉莉",
			"text": "工作太忙了嗎？要不要去喝杯咖啡？",
			"character_image": "res://resources/characters/girl-a-normal.png",
			"background": "res://resources/backgrounds/a-park.png"
		},
		{
			"character": "我",
			"text": "好啊，正好附近有間不錯的咖啡廳。",
			"character_image": "res://resources/characters/girl-a-normal.png",
			"background": "res://resources/backgrounds/a-park.png",
			"choices": [
				{
					"text": "一起去吧！",
					"next_dialogue": "feeling_happy_end"
				}
			]
		}
	],
	"feeling_route_3": [
		{
			"character": "莉莉",
			"text": "欸？是發生什麼事了嗎？",
			"character_image": "res://resources/characters/girl-a-surprise.png",
			"background": "res://resources/backgrounds/a-park.png"
		},
		{
			"character": "我",
			"text": "其實...",
			"character_image": "res://resources/characters/girl-a-sad.png",
			"background": "res://resources/backgrounds/a-park.png",
			"choices": [
				{
					"text": "我想多聊聊...",
					"next_dialogue": "feeling_happy_end"
				},
				{
					"text": "算了，不說也罷",
					"next_dialogue": "stalker_route_2"
				}
			]
		}
	],
	"feeling_happy_end": [
		{
			"is_ending": true,
			"ending_text": "傾訴結局：你們聊了很久，心情好多了。",
			"background": "res://resources/endings/ending-home.png"
		}
	],
	"stalker_route_1": [
		{
			"character": "莉莉",
			"text": "咦？你怎麼知道我會在這裡？",
			"character_image": "res://resources/characters/girl-a-surprise.png",
			"background": "res://resources/backgrounds/a-park.png"
		},
		{
			"character": "我",
			"text": "這個嘛...",
			"character_image": "res://resources/characters/girl-a-normal.png",
			"background": "res://resources/backgrounds/a-park.png",
			"choices": [
				{
					"text": "我常常看到你在這裡散步",
					"next_dialogue": "stalker_route_2"
				},
				{
					"text": "只是碰巧啦！",
					"next_dialogue": "stalker_route_3"
				}
			]
		}
	],
	"stalker_route_2": [
		{
			"character": "莉莉",
			"text": "你該不會一直在觀察我吧？",
			"character_image": "res://resources/characters/girl-a-angry.png",
			"background": "res://resources/backgrounds/a-park.png"
		},
		{
			"is_ending": true,
			"ending_text": "壞結局：你被當成了跟蹤狂...",
			"background": "res://resources/endings/ending-fail.png"
		}
	],
	"stalker_route_3": [
		{
			"character": "莉莉",
			"text": "真的嗎？怎麼感覺怪怪的...",
			"character_image": "res://resources/characters/girl-a-sad.png",
			"background": "res://resources/backgrounds/a-park.png",
			"choices": [
				{
					"text": "其實我有事想跟你說...",
					"next_dialogue": "stalker_route_2"
				},
				{
					"text": "抱歉，我先走了",
					"next_dialogue": "feeling_route_2"
				}
			]
		}
	]
}

func _ready():
	# 連接重新開始按鈕的信號
	$UIRoot/RestartButton.pressed.connect(_on_restart_button_pressed)
	restart_game()

func restart_game():
	# 重置遊戲狀態
	current_dialogue = test_dialogue
	current_index = 0
	
	# 重置UI
	$UIRoot/DialoguePanel.visible = true
	$UIRoot/DialoguePanel.modulate.a = 1
	$UIRoot/DialoguePanel/CharacterName.visible = true
	$UIRoot/CharacterSprite.visible = true
	$UIRoot/ChoicePanel.visible = false
	$UIRoot/RestartButton.visible = false
	
	# 顯示初始對話
	show_current_dialogue()

func show_current_dialogue():
	if current_index >= len(current_dialogue):
		return
		
	var dialogue = current_dialogue[current_index]
	
	# 檢查是否為結局
	if dialogue.has("is_ending"):
		show_ending(dialogue)
		return
		
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

func show_ending(ending_data):
	# 隱藏角色
	$UIRoot/CharacterSprite.visible = false
	
	# 隱藏角色名稱
	$UIRoot/DialoguePanel/CharacterName.visible = false
	
	# 設置並顯示結局文字
	$UIRoot/DialoguePanel/DialogueText.text = ending_data["ending_text"]
	$UIRoot/DialoguePanel/DialogueText.visible = true
	
	# 保持對話框面板可見，但調整其透明度
	$UIRoot/DialoguePanel.modulate.a = 0.8
	
	# 更新背景
	if ending_data.has("background"):
		var texture = load(ending_data["background"])
		if texture:
			$UIRoot/Background.texture = texture
	
	# 顯示重新開始按鈕
	$UIRoot/RestartButton.visible = true

func _on_restart_button_pressed():
	restart_game()

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
