extends Node3D

@export var image_fps:= 30 
@export var animation_lenght:= 0.633
@export var animation_prefix:= "Run" 
@export var frame_correction:= 5

var frame_counter: int = 0
var save_path: String = "user://captured_frames/"
var total_frames: int

func _ready() -> void:
	# Calculate total frames
	total_frames = int(animation_lenght * image_fps) + frame_correction
	
	# Ensure the save directory exists
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(save_path):
		dir.make_dir_recursive(save_path)
	
	print("Saving images to:", ProjectSettings.globalize_path(save_path))
	
	# Start a timer to capture frames
	var timer = Timer.new()
	timer.wait_time = 1.0 / image_fps
	timer.timeout.connect(_capture_frame)
	add_child(timer)
	timer.start()

func _capture_frame() -> void:
	if frame_counter >= total_frames:
		var global_path = ProjectSettings.globalize_path(save_path)
		print("Finished capturing. Frames saved in:", global_path)
		OS.shell_open(global_path) # open folder
		queue_free()  # Free the node after capturing all frames
		return

	var image: Image = get_viewport().get_texture().get_image()
	if image:
		image.convert(Image.FORMAT_RGBA8)
		var file_name = save_path + "%s_%05d.png" % [animation_prefix, frame_counter]
		image.save_png(file_name)
		frame_counter += 1
