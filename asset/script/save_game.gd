const file_name= "user://save_file_path.json";
const save_file_password = "fwegfuywe7r632r732fdjghfvjhfesedwfcdewqyhfewjf"

func saveGame(data):
	var file = File.new()
	file.open_encrypted_with_pass(file_name, File.WRITE,save_file_password)
	file.store_var(to_json(data), true)
	file.close()

func loadGame():
	var loadParam = null
	var file = File.new()
	if not file.file_exists(file_name):
		return loadParam
	file.open_encrypted_with_pass(file_name, File.READ,save_file_password)
	loadParam = parse_json(file.get_var(true))
	file.close()
	return loadParam
