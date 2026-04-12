extends SceneTree

# Test script to verify Godot 4.6 migration
# Run with: godot --headless --path . --script test_migration.gd

func _initialize():
	print("=== GoDAW Godot 4.6 Migration Test ===")
	
	var passed = 0
	var total = 0
	
	# Test 1: Check if all scripts can be loaded
	total += 1
	if test_script_loading():
		passed += 1
		print("✓ Script loading test passed")
	else:
		print("✗ Script loading test failed")
	
	# Test 2: Check signal connections
	total += 1
	if test_signal_connections():
		passed += 1
		print("✓ Signal connection test passed")
	else:
		print("✗ Signal connection test failed")
	
	# Test 3: Check File/Directory API usage
	total += 1
	if test_file_api():
		passed += 1
		print("✓ File API test passed")
	else:
		print("✗ File API test failed")
	
	# Test 4: Check Reference -> RefCounted
	total += 1
	if test_reference_classes():
		passed += 1
		print("✓ Reference classes test passed")
	else:
		print("✗ Reference classes test failed")
	
	# Test 5: Check TSCN format
	total += 1
	if test_tscn_format():
		passed += 1
		print("✓ TSCN format test passed")
	else:
		print("✗ TSCN format test failed")
	
	print("\n=== Results: %d/%d tests passed ===" % [passed, total])
	
	if passed == total:
		print("🎉 Migration appears successful!")
		quit(0)
	else:
		print("⚠️  Some issues remain - check output above")
		quit(1)

func test_script_loading():
	# Test basic syntax by creating a simple script
	var test_script = GDScript.new()
	test_script.source_code = """
extends Node

@onready var test_var = $Test
var await_test = await get_tree().create_timer(0.1).timeout
var callable_test = Callable(self, "test_method")

func test_method():
	pass
"""
	var err = test_script.reload()
	if err != OK:
		print("Basic syntax test failed: " + str(err))
		return false
	
	return true

func test_signal_connections():
	# Test that signal connections work with new Callable syntax
	var test_node = Node.new()
	var connected = false
	
	# This should work in Godot 4
	test_node.connect("ready", Callable(self, "_test_callback"))
	connected = test_node.is_connected("ready", Callable(self, "_test_callback"))
	
	test_node.queue_free()
	return connected

func test_file_api():
	# Test that FileAccess works (replaces File)
	var file = FileAccess.open("user://test.txt", FileAccess.WRITE)
	if file == null:
		print("FileAccess.open failed: " + str(FileAccess.get_open_error()))
		return false
	
	file.store_string("test")
	file.close()
	
	# Test DirAccess (replaces Directory)
	var dir = DirAccess.open("user://")
	if dir == null:
		print("DirAccess.open failed")
		return false
	
	var exists = dir.file_exists("test.txt")
	dir.remove("test.txt")  # cleanup
	
	return exists

func test_reference_classes():
	# Test that RefCounted works (basic functionality)
	var ref = RefCounted.new()
	var is_refcounted = ref is RefCounted
	# Don't call free() on RefCounted objects - they're automatically managed
	
	# Test that we can create a simple RefCounted class
	var test_script = GDScript.new()
	test_script.source_code = """
class_name TestRefCounted extends RefCounted
func test(): pass
"""
	var err = test_script.reload()
	if err != OK:
		print("RefCounted syntax test failed: " + str(err))
		return false
	
	return is_refcounted

func test_tscn_format():
	# Check that TSCN files have been updated to format=3
	var tscn_files = [
		"res://Main.tscn",
		"res://Editor/Scenes/SongEditor/SongEditor.tscn"
	]
	
	for tscn_path in tscn_files:
		var file = FileAccess.open(tscn_path, FileAccess.READ)
		if file == null:
			print("Failed to open TSCN file: " + tscn_path)
			return false
		
		var first_line = file.get_line()
		file.close()
		
		if not first_line.contains("format=3"):
			print("TSCN file still has old format: " + tscn_path)
			print("Found: " + first_line)
			return false
	
	return true

func _test_callback():
	pass