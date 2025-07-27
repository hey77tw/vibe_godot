extends CanvasLayer

# 遊戲資料
var dialogue_data = {}
var current_dialogue = [] # 當前對話內容
var current_step = 0 # 當前對話步驟
var is_showing_choices = false # 是否正在顯示選項

func _ready():
	# 載入對話資料
	load_data()
	# 連接重新開始按鈕
	$UIRoot/RestartButton.pressed.connect(restart_game)
	# 開始遊戲
	start_game()

# 處理滑鼠點擊
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_showing_choices and $UIRoot/RestartButton.visible == false:
			next_dialogue()

# 載入JSON資料
func load_data():
	var file = FileAccess.open("res://dialogue_data.json", FileAccess.READ)
	var json = JSON.new()
	json.parse(file.get_as_text())
	dialogue_data = json.data
	file.close()

# 開始遊戲
func start_game():
	# 重置UI
	$UIRoot/DialoguePanel.visible = true
	$UIRoot/ChoicePanel.visible = false
	$UIRoot/RestartButton.visible = false
	$UIRoot/CharacterSprite.visible = true
	$UIRoot/DialoguePanel/DialogueText.text = ""
	$UIRoot/DialoguePanel/CharacterName.text = ""
	
	# 開始第一段對話
	current_dialogue = dialogue_data["initial_dialogue"]
	current_step = 0
	is_showing_choices = false
	show_current_dialogue()

# 顯示當前對話
func show_current_dialogue():
	if current_step >= current_dialogue.size():
		return
	
	var dialogue = current_dialogue[current_step]
	
	# 顯示角色名字
	if dialogue.has("character"):
		$UIRoot/DialoguePanel/CharacterName.text = dialogue["character"]
	else:
		$UIRoot/DialoguePanel/CharacterName.text = ""
	
	# 顯示對話文字
	$UIRoot/DialoguePanel/DialogueText.text = dialogue["text"]
	
	# 更換圖片
	if dialogue.has("character_image"):
		$UIRoot/CharacterSprite.texture = load(dialogue["character_image"])
	if dialogue.has("background"):
		$UIRoot/Background.texture = load(dialogue["background"])
	
	# 檢查是否有選項
	if dialogue.has("choices"):
		show_choices(dialogue["choices"])
	else:
		is_showing_choices = false

# 顯示選項
func show_choices(choices):
	is_showing_choices = true
	$UIRoot/ChoicePanel.visible = true
	
	# 清空舊選項
	for child in $UIRoot/ChoicePanel/ChoiceContainer.get_children():
		child.queue_free()
	
	# 創建新選項
	for i in range(choices.size()):
		var button = Button.new()
		button.text = choices[i]["text"]
		button.pressed.connect(func(): choice_selected(choices[i]))
		$UIRoot/ChoicePanel/ChoiceContainer.add_child(button)

# 選項被選擇
func choice_selected(choice):
	$UIRoot/ChoicePanel.visible = false
	is_showing_choices = false
	
	# 玩家說出選擇的話
	$UIRoot/DialoguePanel/CharacterName.text = "我"
	$UIRoot/DialoguePanel/DialogueText.text = choice["text"]
	
	# 等一下再繼續
	await get_tree().create_timer(1.0).timeout
	
	# 根據選項跳轉
	if choice.has("next_ending"):
		show_ending(choice["next_ending"])
	elif choice.has("next_dialogue"):
		current_dialogue = dialogue_data["routes"][choice["next_dialogue"]]
		current_step = 0
		show_current_dialogue()

# 顯示結局
func show_ending(ending_name):
	var ending = dialogue_data["endings"][ending_name]
	
	# 隱藏角色，顯示結局
	$UIRoot/CharacterSprite.visible = false
	$UIRoot/DialoguePanel/CharacterName.text = ""
	$UIRoot/DialoguePanel/DialogueText.text = ending["ending_text"]
	$UIRoot/Background.texture = load(ending["background"])
	
	# 2秒後顯示重新開始按鈕
	await get_tree().create_timer(2.0).timeout
	$UIRoot/RestartButton.visible = true

# 下一句對話
func next_dialogue():
	current_step += 1
	show_current_dialogue()

# 重新開始
func restart_game():
	start_game()
