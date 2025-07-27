extends CanvasLayer

# 這是一個對話系統腳本
# 主要功能：顯示對話、處理選項、展示結局
# 適合程式初學者學習

# ===== 遊戲設定 =====
# 按鈕的高度
const CHOICE_BUTTON_HEIGHT = 60
# 對話資料檔案的位置
const DIALOGUE_FILE_PATH = "res://dialogue_data.json"

# ===== 遊戲狀態變數 =====
# 目前的對話內容（一串對話）
var current_dialogue = []
# 目前顯示到第幾句對話
var current_index = 0
# 從檔案讀取的所有對話資料
var dialogue_data = {}
# 所有對話路線
var dialogue_routes = {}
# 所有結局
var endings = {}

# ===== 打字機效果變數 =====
# 打字速度（正常）
var typewriter_speed = 0.08
# 打字速度（快速）
var fast_typewriter_speed = 0.01
# 是否正在打字
var is_typing = false
# 是否要跳過打字效果
var skip_typewriter = false

# ===== 遊戲開始時執行 =====
func _ready():
	print("遊戲開始！載入對話資料...")
	
	# 步驟1：載入對話資料
	load_dialogue_data()
	
	# 步驟2：連接重新開始按鈕
	$UIRoot/RestartButton.pressed.connect(_on_restart_button_pressed)
	
	# 步驟3：開始遊戲
	restart_game()

# ===== 載入對話資料 =====
func load_dialogue_data():
	print("開始載入對話資料...")
	
	# 開啟檔案
	var file = FileAccess.open(DIALOGUE_FILE_PATH, FileAccess.READ)
	if not file:
		print("錯誤：找不到對話資料檔案")
		return
	
	# 讀取檔案內容
	var json_text = file.get_as_text()
	file.close()
	
	# 解析JSON格式
	var json = JSON.new()
	var error = json.parse(json_text)
	
	if error != OK:
		print("錯誤：對話資料格式不正確")
		return
	
	# 將資料存到變數中
	dialogue_data = json.data
	dialogue_routes = dialogue_data["routes"]
	endings = dialogue_data["endings"]
	
	print("對話資料載入完成！")

# ===== 重新開始遊戲 =====
func restart_game():
	print("重新開始遊戲")
	
	# 重置遊戲狀態
	current_dialogue = dialogue_data["initial_dialogue"]
	current_index = 0
	
	# 重置UI元件
	show_dialogue_panel()
	$UIRoot/ChoicePanel.visible = false
	$UIRoot/RestartButton.visible = false
	$UIRoot/CharacterSprite.visible = true
	
	# 開始顯示第一句對話
	show_current_dialogue()

# ===== 顯示對話面板 =====
func show_dialogue_panel():
	$UIRoot/DialoguePanel.visible = true
	$UIRoot/DialoguePanel.modulate.a = 1
	$UIRoot/DialoguePanel/CharacterName.visible = true


# ===== 顯示目前的對話 =====
func show_current_dialogue():
	# 檢查是否還有對話要顯示
	if current_index >= len(current_dialogue):
		print("對話結束")
		return
	
	# 取得目前這句對話的資料
	var dialogue = current_dialogue[current_index]
	
	# 檢查是否為結局
	if dialogue.has("is_ending"):
		show_ending(dialogue)
		return
	
	# 更換角色圖片（如果有的話）
	if dialogue.has("character_image"):
		change_character_image(dialogue["character_image"])
	
	# 更換背景圖片（如果有的話）
	if dialogue.has("background"):
		change_background(dialogue["background"])
	
	# 顯示角色名字
	$UIRoot/DialoguePanel/CharacterName.text = dialogue["character"]
	
	# 用打字機效果顯示對話內容
	var text_to_show = dialogue["text"] + " ▼"
	await start_typewriter_effect(text_to_show)
	
	# 如果這句對話有選項，就顯示選項
	if dialogue.has("choices"):
		show_choices(dialogue["choices"])

# ===== 更換角色圖片 =====
func change_character_image(image_path):
	var texture = load(image_path)
	if texture:
		$UIRoot/CharacterSprite.texture = texture
		print("更換角色圖片：" + image_path)

# ===== 更換背景圖片 =====
func change_background(image_path):
	var texture = load(image_path)
	if texture:
		$UIRoot/Background.texture = texture
		print("更換背景：" + image_path)

# ===== 打字機效果 =====
func start_typewriter_effect(text: String):
	print("開始打字機效果：" + text)
	
	# 設定正在打字的狀態
	is_typing = true
	
	# 清空對話框
	$UIRoot/DialoguePanel/DialogueText.text = ""
	
	# 一個字一個字慢慢顯示
	for i in text.length():
		# 如果玩家點擊加速，就直接顯示全部文字
		if skip_typewriter:
			$UIRoot/DialoguePanel/DialogueText.text = text
			break
		
		# 加上一個字
		$UIRoot/DialoguePanel/DialogueText.text += text[i]
		
		# 等待一小段時間
		await get_tree().create_timer(typewriter_speed).timeout
	
	# 打字完成
	is_typing = false
	skip_typewriter = false
	print("打字機效果完成")

# ===== 顯示結局 =====
func show_ending(ending_data):
	print("顯示結局")
	
	# 隱藏角色
	$UIRoot/CharacterSprite.visible = false
	
	# 隱藏角色名字
	$UIRoot/DialoguePanel/CharacterName.visible = false
	
	# 顯示結局文字
	$UIRoot/DialoguePanel/DialogueText.text = ending_data["ending_text"]
	$UIRoot/DialoguePanel/DialogueText.visible = true
	
	# 讓對話框變半透明
	$UIRoot/DialoguePanel.modulate.a = 0.8
	
	# 更換結局背景
	if ending_data.has("background"):
		change_background(ending_data["background"])
	
	# 等待2秒後顯示重新開始按鈕
	await get_tree().create_timer(2.0).timeout
	$UIRoot/RestartButton.visible = true

# ===== 顯示選項 =====
func show_choices(choices):
	print("顯示選項，共有 " + str(len(choices)) + " 個選項")
	
	# 刪除舊的選項按鈕
	clear_old_choice_buttons()
	
	# 為每個選項創建一個按鈕
	for choice in choices:
		create_choice_button(choice)
	
	# 顯示選項面板
	$UIRoot/ChoicePanel.visible = true

# ===== 清除舊的選項按鈕 =====
func clear_old_choice_buttons():
	for child in $UIRoot/ChoicePanel/ChoiceContainer.get_children():
		child.queue_free()

# ===== 創建選項按鈕 =====
func create_choice_button(choice):
	# 創建新按鈕
	var button = Button.new()
	button.text = choice["text"]
	button.custom_minimum_size = Vector2(0, CHOICE_BUTTON_HEIGHT)
	
	# 當按鈕被點擊時，執行選項被選擇的函式
	button.pressed.connect(_on_choice_selected.bind(choice))
	
	# 將按鈕加到選項容器中
	$UIRoot/ChoicePanel/ChoiceContainer.add_child(button)

# ===== 當選項被選擇時 =====
func _on_choice_selected(choice):
	print("玩家選擇了：" + choice["text"])
	
	# 隱藏選項面板
	$UIRoot/ChoicePanel.visible = false
	
	# 讓主角說出選擇的內容
	var player_dialogue = {
		"character": "我",
		"text": choice["text"]
	}
	
	# 決定接下來要顯示什麼
	if choice.has("next_ending"):
		# 如果是結局，先讓主角說話，然後顯示結局
		handle_ending_choice(player_dialogue, choice)
	elif choice.has("next_dialogue"):
		# 如果是繼續對話，先讓主角說話，然後繼續對話
		handle_dialogue_choice(player_dialogue, choice)

# ===== 處理結局選項 =====
func handle_ending_choice(player_dialogue, choice):
	if endings.has(choice["next_ending"]):
		var ending_data = endings[choice["next_ending"]]
		var ending_dialogue = {
			"is_ending": true,
			"ending_text": ending_data["ending_text"],
			"background": ending_data["background"]
		}
		
		# 組合對話：主角說話 + 結局
		current_dialogue = [player_dialogue, ending_dialogue]
		current_index = 0
		show_current_dialogue()

# ===== 處理對話選項 =====
func handle_dialogue_choice(player_dialogue, choice):
	if dialogue_routes.has(choice["next_dialogue"]):
		# 組合對話：主角說話 + 新的對話路線
		current_dialogue = [player_dialogue] + dialogue_routes[choice["next_dialogue"]]
		current_index = 0
		show_current_dialogue()

# ===== 重新開始按鈕被點擊 =====
func _on_restart_button_pressed():
	print("重新開始按鈕被點擊")
	restart_game()

# ===== 處理玩家輸入（滑鼠點擊） =====
func _input(event):
	# 檢查是否為滑鼠左鍵點擊
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			handle_mouse_click()

# ===== 處理滑鼠點擊 =====
func handle_mouse_click():
	# 如果選項面板正在顯示，就不要進行下一段對話
	if $UIRoot/ChoicePanel.visible:
		return
	
	# 如果正在打字，點擊可以加速
	if is_typing:
		typewriter_speed = fast_typewriter_speed
		skip_typewriter = true
		print("加速打字")
	else:
		# 恢復正常打字速度，進入下一句對話
		typewriter_speed = 0.08
		next_dialogue()

# ===== 進入下一句對話 =====
func next_dialogue():
	print("進入下一句對話")
	current_index += 1
	
	# 檢查是否還有對話
	if current_index < len(current_dialogue):
		show_current_dialogue()
	else:
		print("這個對話路線結束了")
