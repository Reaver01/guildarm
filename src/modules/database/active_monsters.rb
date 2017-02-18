module Bot
  module Database
    # Active Monster table
    class ActiveMonster < Sequel::Model
      many_to_one :monster
      one_to_many :monster_attackers

      include Anger

      include Trap

      # @params channel [Integer] The discord channel id in which you want to spawn a monster
      # @return [Object] The new monster created for the channel, or the current monster if there
      # is already a monster in the channel
      def self.spawn(channel)
        find(channel: channel) || create(
          channel: channel, monster_id: Database::Monster[rand(1..Database::Monster.count)].id
        )
      end

      # @params channel [Integer] The discord channel id you want to check for a current monster
      # @return [Object/Boolean] The current monster if there is a monster in the channel or false
      # if there is no monster in the channel
      def self.current(channel)
        find(channel: channel) || false
      end

      # @params player_id [Integer] The index of the player you want to find an attack from
      # @return [Object] The existing attack object from the player specified or nil if none exist
      def attack(player_id)
        monster_attackers.find { |i| i.player_id == player_id }
      end

      # @params discord_id [Integer] The discord user id of the player that is doing the attacking
      # @params damage_done [Integer] The amount of damage the player is dealing
      def add_attack(discord_id, damage_done = 1)
        player_id = Database::Player.resolve_id(discord_id).id
        existing_attack = attack(player_id)
        if existing_attack
          damage_done += existing_attack.damage_done
          existing_attack.update damage_done: damage_done
        else
          add_monster_attacker player_id: player_id, damage_done: damage_done
        end
      end

      # @params discord_id [Integer] The discord user id of the player
      # @return [Integer] The amount of damage the player has done
      def damage_by(discord_id)
        monster_attackers.find { |e| e.player.discord_id == discord_id }
      end

      # @return [Integer] The total amount of damage done to the monster by players
      def damage
        monster_attackers.map(&:damage_done).reduce(:+) || 0
      end

      # @return [Integer] The amount of health the monster has left
      def hp
        monster.hp - damage
      end

      # @return [Integer] The percentage of health the monster has left (0..100)
      def hp_percent
        percent = hp / monster.hp * 100
        percent.round
      end

      # @return [String] A representation of the monsters health in vague terms
      def health
        if hp_percent >= 60
          %w(Strong Healthy).sample
        elsif (20...60).cover? hp_percent
          %w(Wounded Damaged).sample
        elsif hp_percent < 20
          %w(Limping Weak Feable Dying).sample
        end
      end

      # Gives all players that have done the required amount of damage to the monster 1 HR
      def give_hr
        monster_attackers.each do |attacker|
          if attacker.damage_done > 50 + attacker.player.hr && attacker.player.hr < 100
            attacker.player.update(hr: attacker.player.hr + 1)
          end
        end
      end

      # Moves the monster to the Graveyard channel so a new monster can spawn in the channel later
      def move_to_graveyard
        update(channel: 0)
      end

      # @return [object] embed
      def info_embed
        embed = Discordrb::Webhooks::Embed.new
        embed.title = monster.name
        embed.thumbnail = {
          url: "http://monsterhunteronline.in/monsters/images/#{monster.icon}.png"
        }
        embed.color = monster.color
        embed.description = "Angry: #{angry? ? 'Yes' : 'No'}\n" \
                            "In Trap: #{trapped? ? 'Yes' : 'No'}\n" \
                            "Status: #{health}"
        embed.timestamp = Time.now
        embed
      end

      # @return [object] embed
      def initial_embed
        embed = Discordrb::Webhooks::Embed.new
        embed.title = monster.name
        embed.thumbnail = {
          url: "http://monsterhunteronline.in/monsters/images/#{monster.icon}.png"
        }
        embed.color = monster.color
        embed.description = 'Good Luck!'
        embed.timestamp = Time.now
        embed
      end

      # @return [object] embed
      def death_embed
        embed = Discordrb::Webhooks::Embed.new
        embed.author = {
          name: monster.name,
          icon_url: "http://monsterhunteronline.in/monsters/images/#{monster.icon}.png"
        }
        embed.title = 'Damage Results:'
        embed.thumbnail = { url: 'http://i.imgur.com/0MskAc1.png' }
        embed.color = monster.color
        embed.description = ''
        monster_attackers.sort_by { |e| -1 * e[:damage_done] }.each do |attacker|
          star = if attacker.damage_done > 50 + attacker.player.hr
                   '⭐'
                 else
                   ''
                 end
          embed.description += "**#{attacker.player.user.name}**: #{attacker.damage_done} #{star}\n"
        end
        embed.timestamp = Time.now
        embed
      end
    end
  end
end
