def embed(eName, eDesc)
	e = Discordrb::Webhooks::Embed.new
	e.author = {
		name: eName
	}
	e.color = "%06x" % (rand * 0xffffff)
	e.description = eDesc
	e.timestamp = Time.now
	e
end

def inventory(id, uname)
	desc = "**Zenny:** #{$players[id]['zenny']}\n\n"
	$players[id]['inv'].each do |key, item|
		desc += "**#{$items[key.to_i]['name']}:** #{item.to_i}\n"
	end
	e = Discordrb::Webhooks::Embed.new
	e.author = {
		name: "Here is your inventory #{uname}!",
		icon_url: $bot.profile.avatar_url
	}
	e.color = "%06x" % (rand * 0xffffff)
	e.description = desc
	e
end

def newItems(items, uname)
	desc = ""
	items.each do |item|
		desc += "**#{$items[item]['name']}**\n"
	end
	e = Discordrb::Webhooks::Embed.new
	e.author = {
		name: "Here are the new items you recieved #{uname}!",
		icon_url: $bot.profile.avatar_url
	}
	e.color = "%06x" % (rand * 0xffffff)
	e.description = desc
	e
end

def userInfo(id, uname, avatar)
	invnum = 0
	$players[id]['inv'].each do |key, item|
		invnum += item.to_i
	end
	e = Discordrb::Webhooks::Embed.new
	e.author = {
		name: "This is info all about #{uname}!",
		icon_url: avatar
	}
	e.color = "%06x" % (rand * 0xffffff)
	e.description = "**Level:** #{$players[id]['level']}\n**HR:** #{$players[id]['hr']}\n**XP:** #{$players[id]['xp']}\n**Zenny:** #{$players[id]['zenny']}\n**Inventory:** #{invnum} items"
	e
end

def newMonster(arr)
	e = Discordrb::Webhooks::Embed.new
	e.author = {
		name: arr['name']
	}
	e.color = arr['color']
	e.thumbnail = { url: "http://monsterhunteronline.in/monsters/images/#{arr['icon']}.png" }
	e.description = "Health: #{arr['hp']}"
	e
end

def monster(arr, trap, anger)
	e = Discordrb::Webhooks::Embed.new
	e.author = {
		name: arr['name']
	}
	e.color = arr['color']
	e.thumbnail = { url: "http://monsterhunteronline.in/monsters/images/#{arr['icon']}.png" }
	e.description = "Health: #{arr['hp']}\nAngry: #{anger}\nIn Trap: #{trap}"
	e
end

def huntEnd(arr)
	desc = ''
	players = arr['players'].sort_by {|k,v| v}.reverse.to_h
	players.each do |k,v|
		desc += "**#{arr['players2'][k]}:** #{v}\n"
		if v > 50 + $players[k]['hr']
			$players[k]['hr'] += 1
		end
	end
	e = Discordrb::Webhooks::Embed.new
	e.author = {
		name: "#{arr['name']}",
		icon_url: "http://monsterhunteronline.in/monsters/images/#{arr['icon']}.png"
	}
	e.color = arr['color']
	e.thumbnail = { url: "http://i.imgur.com/idahYG5.png" }
	e.description = desc.chomp("\n")
	e
end
