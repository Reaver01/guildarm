def damage(event_user, event_channel, event_message, event_timestamp)
  if $current_unstable.key?(event_channel.id.to_s)
    old_time = if $current_unstable[event_channel.id.to_s].key?('damage_time')
                 $current_unstable[event_channel.id.to_s]['damage_time']
               else
                 '2017-01-01 00:00:00 +0000'
               end
    damaged_players = {}
    if TimeDifference.between(old_time, event_timestamp).in_minutes > 3
      debug(10, "[DAMAGE] Time between damage on #{event_channel.id} is longer than 3 minutes. Changing timestamp and dealing damage.")
      $current_unstable[event_channel.id.to_s]['damage_time'] = event_timestamp
      if $current_unstable[event_channel.id.to_s].key?('players')
        debug(13, '[DAMAGE] Players have damaged monster. Adding reaction.')
        event_message.react('🎯')
        $current_unstable[event_channel.id.to_s]['players'].each do |key, value|
          damage_done = 0
          if $current_unstable[event_channel.id.to_s].key?('is_dead')
            debug(18, '[DAMAGE] is_dead exists. | Checking for key')
            if $current_unstable[event_channel.id.to_s]['is_dead'].key?(key)
              debug(20, '[DAMAGE] key for is_dead exists. | Checking if key = false')
              unless $current_unstable[event_channel.id.to_s]['is_dead'][key]
                debug(22, "[DAMAGE] key = false | #{key} is not dead. Dealing damage.")
                damage_done = rand(0..value) / 2
              end
            else
              debug(26, "[DAMAGE] key for is_dead doesn't exist | #{key} is not dead. Dealing damage.")
              damage_done = rand(0..value) / 2
            end
          else
            debug(30, "[DAMAGE] is_dead doesn't exist | Nobody is dead. Dealing damage.")
            damage_done = rand(0..value) / 2
          end
          damage_done = damage_done.round
          next if damage_done.zero?
          debug(35, '[DAMAGE] Damage was done | Notifying.')
          if $players.key?(key)
            if $players[key]['messages']
              debug(38, "[DAMAGE] #{key} has messages turned on | Continuing with message.")
              begin
                BOT.user(key).pm("You have taken **#{damage_done} damage** from the **#{$current_unstable[event_channel.id.to_s]['name']}** in **#{event_channel.name}**")
              rescue
                mute_log(key)
              end
            end
            unless $players[key].key?('max_hp')
              debug(46, "[DAMAGE] #{key} doesn't have an HP value in their profile | calculating HP for player.")
              new_hp = 500 + ($players[key]['level'] * 10)
              $players[key]['max_hp'] = new_hp
              $players[key]['current_hp'] = new_hp
            end
          end
          debug(52, '[DAMAGE] Adding player id and damage done to array.')
          damaged_players[key] = damage_done
        end
        damaged_players.each do |key, value|
          next unless $players.key?(key)
          debug(58, '[DAMAGE] Player has profile')
          unless $players[key].key?('current_hp')
            debug(60, "[DAMAGE] #{key} doesn't have an HP value in their profile | calculating HP for player.")
            new_hp = 500 + ($players[key]['level'] * 10)
            $players[key]['max_hp'] = new_hp
            $players[key]['current_hp'] = new_hp
          end
          $players[key]['current_hp'] -= value
          next unless $players[key]['current_hp'] < 0
          debug(67, "[DAMAGE] #{key}'s health < 0 | #{key} is dead.")
          if $players[key]['messages']
            debug(69, "[DAMAGE] #{key} has messages turned on | Continuing with message.")
            begin
              BOT.user(key).pm('You have taken too much damage! The felynes will take approximately 5 minutes to restore you to full power.')
            rescue
              mute_log(key)
            end
          end
          if $current_unstable[event_channel.id.to_s].key?('is_dead')
            debug(77, "[DAMAGE] #{key} has a key in is_dead | Setting to true.")
            $current_unstable[event_channel.id.to_s]['is_dead'][key] = true
          else
            debug(80, "[DAMAGE] Mosnter doesn't have is_dead key | Making key and adding #{key}.")
            $current_unstable[event_channel.id.to_s]['is_dead'] = { key => true }
          end
          debug(83, "[DAMAGE] adding death_time to #{key}s profile.")
          $players[key]['death_time'] = event_timestamp
        end
      end
    end
  end
  if $players.key?(event_user.id.to_s)
    if $players[event_user.id.to_s].key?('death_time')
      debug(93, "[DAMAGE] #{event_user.id} has key for death_time.")
      if TimeDifference.between($players[event_user.id.to_s]['death_time'], event_timestamp).in_minutes > 5
        debug(95, '[DAMAGE] death_time was > 5 minutes ago | Removing key from death_time.')
        $players[event_user.id.to_s] = $players[event_user.id.to_s].without('death_time')
        if $current_unstable.key?(event_channel.id.to_s)
          debug(98, '[DAMAGE] There is a monster in the current channel.')
          if $current_unstable[event_channel.id.to_s].key?('is_dead')
            debug(100, "[DAMAGE] Key for is_dead exists | Reviving #{event_user.id}")
            $current_unstable[event_channel.id.to_s]['is_dead'][event_user.id.to_s] = false
          else
            debug(103, "[DAMAGE] Key for is_dead does not exist | Making one and setting #{event_user.id} to not dead.")
            $current_unstable[event_channel.id.to_s]['is_dead'] = { event_user.id.to_s => false }
          end
        end
        debug(107, "[DAMAGE] Setting #{event_user.id}'s health to max.")
        $players[event_user.id.to_s]['current_hp'] = $players[event_user.id.to_s]['max_hp']
      end
    end
  end
end
