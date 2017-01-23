#JSON Loader
def LoadJSON(file_location)
	if File.exist?(file_location)
		begin
			array = Hash.new
			array = JSON.parse File.read file_location
		rescue
			array = Hash.new
		end
	else
		puts "[LOADER] No file #{file_location} to load!"
	end
	puts "[LOADER] #{file_location} loaded!"
	return array
end
#JSON Loader for Permissions
def LoadPermissions(file_location)
	if File.exist?(file_location)
		begin
			array = Hash.new
			array = JSON.parse File.read file_location
		rescue
			array = Hash.new
		end
	else
		puts '[LOADER] You have not set up any permissions', '[LOADER] Please enter your user id to set admin permissions for your discord account'
		user_id = $stdin.gets.chomp.to_i
		array[user_id] = {'id'=>user_id.to_i, 'lvl'=>999}
		File.open(file_location, 'w') { |f| f.write array.to_json }
		puts '[LOADER] Permissions saved!'
	end
	puts "[LOADER] #{file_location} loaded!"
	return array
end