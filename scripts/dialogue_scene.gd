extends CanvasLayer

# 使用dokivn addon的對話系統腳本
# 主要功能：顯示對話、處理選項、展示結局
# 適合程式初學者學習

# ===== 遊戲設定 =====
# 對話資料檔案的位置
const DIALOGUE_FILE_PATH = "res://dialogue_data.json"

# ===== dokivn系統 =====
# 主要的腳本管理器
var scripted: Scripted
# 角色字典
var characters: Dictionary = {}

# ===== 遊戲狀態變數 =====
# 從檔案讀取的所有對話資料
var dialogue_data = {}
# 所有對話路線
var dialogue_routes = {}
# 所有結局
var endings = {}
# 目前是否在遊戲中
var game_running = false

# ===== 遊戲開始時執行 =====
func _ready():
	print("遊戲開始！載入對話資料...")
	
	# 初始化dokivn系統
	scripted = Scripted.new()
	scripted.from = self
	
	# 連接確認信號到滑鼠點擊
	scripted.confirm.connect(_on_dialogue_confirm)
	
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
	
	# 如果遊戲正在運行，停止它
	if game_running:
		# 重新初始化scripted系統
		scripted = Scripted.new()
		scripted.from = self
		scripted.confirm.connect(_on_dialogue_confirm)
	
	# 重置UI元件
	$UIRoot/DialoguePanel.visible = true
	$UIRoot/DialoguePanel.modulate.a = 1
	$UIRoot/DialoguePanel/CharacterName.visible = true
	$UIRoot/ChoicePanel.visible = false
	$UIRoot/RestartButton.visible = false
	$UIRoot/CharacterSprite.visible = true
	
	# 清空顯示
	$UIRoot/DialoguePanel/DialogueText.text = ""
	$UIRoot/DialoguePanel/CharacterName.text = ""
	
	# 創建角色
	setup_characters()
	
	# 開始執行對話腳本
	game_running = true
	execute_initial_dialogue()

# ===== 設定角色 =====
func setup_characters():
	characters.clear()
	# 創建一個預設角色（可以根據需要擴展）
	characters["default"] = scripted.character().name("角色").color(Color.WHITE)
	characters["我"] = scripted.character().name("我").color(Color.CYAN)

# ===== 執行初始對話 =====
func execute_initial_dialogue():
	if dialogue_data.has("initial_dialogue"):
		# 創建對話樹結構
		setup_dialogue_tree(dialogue_data["initial_dialogue"])
		# 啟動dokivn系統
		scripted.start()
	else:
		print("沒有找到初始對話資料")

# ===== 設定對話樹結構 =====
func setup_dialogue_tree(dialogue_sequence: Array):
	for dialogue in dialogue_sequence:
		add_dialogue_to_tree(dialogue)

# ===== 將對話加入樹狀結構 =====
func add_dialogue_to_tree(dialogue: Dictionary):
	# 更換角色圖片（如果有的話）
	if dialogue.has("character_image"):
		var img_path = dialogue["character_image"]
		scripted.register(VNTree.Jump.new(func(): change_character_image(img_path), []))
	
	# 更換背景圖片（如果有的話）
	if dialogue.has("background"):
		var bg_path = dialogue["background"]
		scripted.register(VNTree.Jump.new(func(): change_background(bg_path), []))
	
	# 檢查是否為結局
	if dialogue.has("is_ending"):
		scripted.register(VNTree.Jump.new(func(): await show_ending(dialogue), []))
		return
	
	# 取得角色名稱和顯示對話
	var character_name = dialogue.get("character", "")
	var text_to_show = dialogue["text"]
	var character = get_or_create_character(character_name)
	var character_id = character.attr_address if character else scripted.NO_CHAR
	
	# 將對話加入樹狀結構
	scripted.register(VNTree.DialogText.new(character_id, text_to_show))
	
	# 如果這句對話有選項，就加入選項
	if dialogue.has("choices"):
		var choice_option = scripted.choices("請選擇：")
		for choice in dialogue["choices"]:
			var choice_text = choice["text"]
			var callback = create_choice_callback_for_tree(choice)
			choice_option.option(choice_text, callback)

# ===== 創建選項回調函數（用於樹狀結構） =====
func create_choice_callback_for_tree(choice: Dictionary) -> Callable:
	return func():
		# 讓主角說出選擇的內容
		var player_character = get_or_create_character("我")
		scripted.register(VNTree.DialogText.new(player_character.attr_address, choice["text"]))
		
		# 決定接下來要顯示什麼
		if choice.has("next_ending"):
			handle_ending_choice_for_tree(choice)
		elif choice.has("next_dialogue"):
			handle_dialogue_choice_for_tree(choice)

# ===== 處理結局選項（用於樹狀結構） =====
func handle_ending_choice_for_tree(choice: Dictionary):
	if endings.has(choice["next_ending"]):
		var ending_data = endings[choice["next_ending"]]
		var ending_dialogue = {
			"is_ending": true,
			"ending_text": ending_data["ending_text"],
			"background": ending_data["background"]
		}
		add_dialogue_to_tree(ending_dialogue)

# ===== 處理對話選項（用於樹狀結構） =====
func handle_dialogue_choice_for_tree(choice: Dictionary):
	if dialogue_routes.has(choice["next_dialogue"]):
		setup_dialogue_tree(dialogue_routes[choice["next_dialogue"]])

# ===== 執行對話序列 =====
func execute_dialogue_sequence(dialogue_sequence: Array):
	for dialogue in dialogue_sequence:
		await execute_single_dialogue(dialogue)

# ===== 執行單句對話 =====
func execute_single_dialogue(dialogue: Dictionary):
	# 檢查是否為結局
	if dialogue.has("is_ending"):
		await show_ending(dialogue)
		return
	
	# 更換角色圖片（如果有的話）
	if dialogue.has("character_image"):
		change_character_image(dialogue["character_image"])
	
	# 更換背景圖片（如果有的話）
	if dialogue.has("background"):
		change_background(dialogue["background"])
	
	# 取得或創建角色
	var character_name = dialogue.get("character", "")
	var character = get_or_create_character(character_name)
	
	# 讓角色說話
	var text_to_show = dialogue["text"]
	if character:
		character.says(text_to_show)
	else:
		scripted.says(text_to_show)
	
	# 如果這句對話有選項，就顯示選項
	if dialogue.has("choices"):
		await handle_choices(dialogue["choices"])

# ===== 取得或創建角色 =====
func get_or_create_character(character_name: String) -> VNChar:
	if character_name.is_empty():
		return null
	
	if not characters.has(character_name):
		characters[character_name] = scripted.character().name(character_name).color(Color.WHITE)
	
	return characters[character_name]

# ===== 處理選項 =====
func handle_choices(choices: Array):
	# 創建選項組
	var choice_option = scripted.choices("請選擇：")
	
	# 為每個選項創建回調
	for choice in choices:
		var choice_text = choice["text"]
		var callback = create_choice_callback(choice)
		choice_option.option(choice_text, callback)

# ===== 創建選項回調函數 =====
func create_choice_callback(choice: Dictionary) -> Callable:
	return func():
		# 讓主角說出選擇的內容
		var player_character = get_or_create_character("我")
		player_character.says(choice["text"])
		
		# 決定接下來要顯示什麼
		if choice.has("next_ending"):
			await handle_ending_choice(choice)
		elif choice.has("next_dialogue"):
			await handle_dialogue_choice(choice)

# ===== 處理結局選項 =====
func handle_ending_choice(choice: Dictionary):
	if endings.has(choice["next_ending"]):
		var ending_data = endings[choice["next_ending"]]
		var ending_dialogue = {
			"is_ending": true,
			"ending_text": ending_data["ending_text"],
			"background": ending_data["background"]
		}
		await show_ending(ending_dialogue)

# ===== 處理對話選項 =====
func handle_dialogue_choice(choice: Dictionary):
	if dialogue_routes.has(choice["next_dialogue"]):
		await execute_dialogue_sequence(dialogue_routes[choice["next_dialogue"]])

# ===== 顯示結局 =====
func show_ending(ending_data: Dictionary):
	print("顯示結局")
	
	# 隱藏角色
	$UIRoot/CharacterSprite.visible = false
	
	# 更換結局背景
	if ending_data.has("background"):
		change_background(ending_data["background"])
	
	# 顯示結局文字 - 使用樹狀結構方式
	scripted.register(VNTree.DialogText.new(scripted.NO_CHAR, ending_data["ending_text"]))
	
	# 設定半透明效果
	scripted.register(VNTree.Opacity.new(0.8))
	
	# 等待2秒後顯示重新開始按鈕
	scripted.register(VNTree.WaitTime.new(false, 2.0))
	scripted.register(VNTree.Jump.new(show_restart_button, []))

# ===== 顯示重新開始按鈕 =====
func show_restart_button():
	$UIRoot/RestartButton.visible = true
	game_running = false

# ===== 更換角色圖片 =====
func change_character_image(image_path: String):
	var texture = load(image_path)
	if texture:
		$UIRoot/CharacterSprite.texture = texture
		print("更換角色圖片：" + image_path)

# ===== 更換背景圖片 =====
func change_background(image_path: String):
	var texture = load(image_path)
	if texture:
		$UIRoot/Background.texture = texture
		print("更換背景：" + image_path)

# ===== 重新開始按鈕被點擊 =====
func _on_restart_button_pressed():
	print("重新開始按鈕被點擊")
	restart_game()

# ===== 對話確認事件 =====
func _on_dialogue_confirm():
	# 這個函數會在滑鼠點擊時被呼叫
	# dokivn系統會自動處理對話推進，這裡可以加入額外的邏輯
	print("對話確認 - 滑鼠點擊")

# ===== 處理玩家輸入（滑鼠點擊） =====
func _input(event):
	# 檢查是否為滑鼠左鍵點擊且遊戲正在運行
	if event is InputEventMouseButton and game_running:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# 發送確認信號給dokivn系統
			scripted.confirm.emit()

# ===== 更新顯示 =====
func _process(_delta):
	if not game_running or not scripted:
		return
	
	# 更新對話文字
	$UIRoot/DialoguePanel/DialogueText.text = scripted.text_output
	$UIRoot/DialoguePanel/DialogueText.visible_ratio = scripted.vrat_output
	
	# 更新角色名字
	var current_char = scripted.get_character()
	if current_char:
		$UIRoot/DialoguePanel/CharacterName.text = current_char.attr_name
		$UIRoot/DialoguePanel/CharacterName.modulate = current_char.attr_color
	else:
		$UIRoot/DialoguePanel/CharacterName.text = ""
		$UIRoot/DialoguePanel/CharacterName.modulate = Color.WHITE
	
	# 更新透明度
	$UIRoot/DialoguePanel.modulate.a = scripted.opacity_output
	$UIRoot/DialoguePanel/CharacterName.modulate.a = scripted.opacity_output
