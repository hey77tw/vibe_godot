extends CanvasLayer

## 對話系統控制器
## 處理對話內容的顯示、選項選擇和結局展示
## 包含對話數據的加載和管理功能

const CHOICE_BUTTON_HEIGHT = 60
const DIALOGUE_FILE_PATH = "res://dialogue_data.json"

var current_dialogue = []
var current_index = 0
var dialogue_data = {}
var dialogue_routes = {}
var endings = {}

# 打字機效果相關變數
var typewriter_speed := 0.08
var fast_typewriter_speed := 0.01
var is_typing := false
var skip_typewriter := false


func load_dialogue_data():
	var file = FileAccess.open(DIALOGUE_FILE_PATH, FileAccess.READ)
	if not file:
		push_error("無法開啟對話資料檔案：" + DIALOGUE_FILE_PATH)
		return
		
	var json_text = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_text)
	
	if error != OK:
		push_error("JSON 解析錯誤：" + json.get_error_message())
		return
		
	dialogue_data = json.data
	dialogue_routes = dialogue_data["routes"]
	endings = dialogue_data["endings"]

func _ready():
	# 載入對話資料
	load_dialogue_data()
	
	# 連接重新開始按鈕的信號
	$UIRoot/RestartButton.pressed.connect(_on_restart_button_pressed)
	restart_game()

func restart_game():
	# 重置遊戲狀態
	current_dialogue = dialogue_data["initial_dialogue"] if dialogue_data.has("initial_dialogue") else []
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

func typewriter_effect(label, text: String) -> void:
	is_typing = true
	label.text = ""
	for i in text.length():
		if skip_typewriter:
			label.text = text
			break
		label.text += text[i]
		await get_tree().create_timer(typewriter_speed).timeout
	is_typing = false
	skip_typewriter = false

func show_current_dialogue():
	if current_index >= len(current_dialogue):
		return
		
	var dialogue = current_dialogue[current_index]
	
	# 檢查是否為結局
	if dialogue.has("is_ending"):
		show_ending(dialogue)
		return
		
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

	$UIRoot/DialoguePanel/CharacterName.text = dialogue["character"]
	# 用打字機效果顯示對話，結尾自動加上 ▼
	var display_text = dialogue["text"] + " ▼"
	await typewriter_effect($UIRoot/DialoguePanel/DialogueText, display_text)
	
			
	# 如果有選項
	if dialogue.has("choices"):
		show_choices(dialogue["choices"])

func show_ending(ending_data):
	# 隱藏角色
	$UIRoot/CharacterSprite.visible = false
	
	# 隱藏角色名稱
	$UIRoot/DialoguePanel/CharacterName.visible = false
	
	# 設置並顯示結局文字，結尾自動加上 ▼
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
		button.custom_minimum_size = Vector2(0, CHOICE_BUTTON_HEIGHT)
		button.pressed.connect(_on_choice_selected.bind(choice))
		$UIRoot/ChoicePanel/ChoiceContainer.add_child(button)
	
	# 顯示選項面板
	$UIRoot/ChoicePanel.visible = true

func _on_choice_selected(choice):
	# 隱藏選項面板
	$UIRoot/ChoicePanel.visible = false
	
	# 檢查是否為結局
	if choice.has("next_ending") and endings.has(choice["next_ending"]):
		show_ending(endings[choice["next_ending"]])
	# 切換到選擇的對話路線
	elif choice.has("next_dialogue") and dialogue_routes.has(choice["next_dialogue"]):
		current_dialogue = dialogue_routes[choice["next_dialogue"]]
		current_index = 0
		show_current_dialogue()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# 如果選項面板可見，不要進行下一段對話
			if not $UIRoot/ChoicePanel.visible:
				# 如果正在打字，點擊加速
				if is_typing:
					typewriter_speed = fast_typewriter_speed
					skip_typewriter = true
				else:
					typewriter_speed = 0.08 # 恢復預設速度
					next_dialogue()

func next_dialogue():
	current_index += 1
	if current_index < len(current_dialogue):
		show_current_dialogue()
