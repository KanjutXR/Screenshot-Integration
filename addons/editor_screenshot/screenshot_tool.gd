@tool
extends EditorPlugin

# CONFIGURATION
var webhook_url = "YOUR_DISCORD_WEBHOOK_URL_HERE"

# UI ELEMENTS
var http_request: HTTPRequest
var toolbar_button: Button
var dialog: ConfirmationDialog
var input_title: LineEdit
var input_desc: TextEdit

func _enter_tree():
	# 1. Add Button to Editor Toolbar
	toolbar_button = Button.new()
	toolbar_button.text = "Picture"
	toolbar_button.pressed.connect(_show_input_dialog)
	add_control_to_container(CONTAINER_TOOLBAR, toolbar_button)
	
	# 2. Setup HTTPRequest
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	
	_create_gui_dialog()

func _exit_tree():
	remove_control_from_container(CONTAINER_TOOLBAR, toolbar_button)
	toolbar_button.queue_free()
	if dialog: dialog.queue_free()

func _create_gui_dialog():
	dialog = ConfirmationDialog.new()
	dialog.title = "Send Progress to Discord"
	dialog.get_ok_button().text = "Send Now"
	
	var container = VBoxContainer.new()
	
	var label_t = Label.new()
	label_t.text = "Progress Title:"
	input_title = LineEdit.new()
	input_title.placeholder_text = "e.g., Finished Main Menu UI"
	
	var label_d = Label.new()
	label_d.text = "Description / Notes:"
	input_desc = TextEdit.new()
	input_desc.custom_minimum_size = Vector2(0, 100)
	input_desc.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	
	container.add_child(label_t)
	container.add_child(input_title)
	container.add_child(label_d)
	container.add_child(input_desc)
	
	dialog.add_child(container)
	EditorInterface.get_base_control().add_child(dialog)
	dialog.confirmed.connect(_on_dialog_confirmed)

func _show_input_dialog():
	dialog.popup_centered(Vector2i(400, 350))

func _on_dialog_confirmed():
	# HIDE UI elements so they don't appear in the screenshot
	dialog.visible = false
	toolbar_button.visible = false
	
	# Wait for the GPU to finish rendering the frame WITHOUT the UI
	await RenderingServer.frame_post_draw
	
	_capture_and_send()
	
	# Show the button again after capture
	toolbar_button.visible = true

func _capture_and_send():
	toolbar_button.disabled = true
	toolbar_button.text = "Sending..."
	
	# Capture Editor Viewport
	var editor_viewport = EditorInterface.get_base_control().get_viewport()
	var image = editor_viewport.get_texture().get_image()
	var image_data = image.save_png_to_buffer()
	
	# Prepare Discord Embed Payload
	var payload = {
		"embeds": [{
			"title": input_title.text if input_title.text != "" else "Godot Progress Update",
			"description": input_desc.text if input_desc.text != "" else "No description provided.",
			"color": 5814783, # Godot Blue
			"image": {"url": "attachment://screenshot.png"},
			"footer": {"text": "Sent from Godot 4 Mobile Editor • " + Time.get_datetime_string_from_system()}
		}]
	}
	
	_send_multipart(image_data, JSON.stringify(payload))

func _send_multipart(image_data: PackedByteArray, json_payload: String):
	var boundary = "GodotUploadBoundary"
	var headers = ["Content-Type: multipart/form-data; boundary=" + boundary]
	var body = PackedByteArray()
	
	# Part 1: JSON Payload
	body.append_array(("--" + boundary + "\r\n").to_utf8_buffer())
	body.append_array(("Content-Disposition: form-data; name=\"payload_json\"\r\n").to_utf8_buffer())
	body.append_array(("Content-Type: application/json\r\n\r\n").to_utf8_buffer())
	body.append_array((json_payload + "\r\n").to_utf8_buffer())
	
	# Part 2: Image File
	body.append_array(("--" + boundary + "\r\n").to_utf8_buffer())
	body.append_array(("Content-Disposition: form-data; name=\"file\"; filename=\"screenshot.png\"\r\n").to_utf8_buffer())
	body.append_array(("Content-Type: image/png\r\n\r\n").to_utf8_buffer())
	body.append_array(image_data)
	body.append_array(("\r\n--" + boundary + "--\r\n").to_utf8_buffer())
	
	var err = http_request.request_raw(webhook_url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		_handle_error("Failed!")

func _on_request_completed(_result, response_code, _headers, _body):
	if response_code == 200 or response_code == 204:
		toolbar_button.text = "Success!"
		input_title.text = ""
		input_desc.text = ""
		await get_tree().create_timer(2.0).timeout
		_reset_button()
	else:
		_handle_error("Error: " + str(response_code))

func _handle_error(msg: String):
	toolbar_button.text = msg
	toolbar_button.modulate = Color.RED
	await get_tree().create_timer(2.5).timeout
	_reset_button()

func _reset_button():
	toolbar_button.disabled = false
	toolbar_button.text = "Picture"
	toolbar_button.modulate = Color.WHITE
	toolbar_button.visible = true