class HeadStrong < RTanque::Bot::Brain
  NAME = 'HeadStrong'
  include RTanque::Bot::BrainHelper

  def tick!
    @ticks_since_rotation_change ||= 0
    @previous_health ||= sensors.health
    command.speed = MAX_BOT_SPEED
    new_heading = sensors.heading + 0.05 * rotation_speed
    command.heading = new_heading
    if closest_bot
      command.turret_heading = closest_bot.heading
      if closest_bot.distance < firing_range
        command.radar_heading = closest_bot.heading
      else
        command.radar_heading = sensors.radar_heading + 0.1 * rotation_speed
      end
      command.fire_power = 5 - (5 * closest_bot.distance / firing_range)
      command.fire
    else
      command.radar_heading = sensors.radar_heading + 0.1 * rotation_speed
    end
    @previous_health = sensors.health
    @ticks_since_rotation_change += 1
  end

  def firing_range
    @firing_range ||= (arena.height + arena.width) / 4
  end

  def distance_from_wall(wall)
    case wall.to_sym
    when :top
      arena.height - sensors.position.y
    when :bottom
      sensors.position.y
    when :left
      sensors.position.x
    when :right
      arena.width - sensors.position.x
    end
  end

  def rotation_speed
    @clockwise ||= false
    if sensors.health < @previous_health && @ticks_since_rotation_change < 50
      @clockwise = !@clockwise
      @ticks_since_rotation_change = 0
    end
    1 * (@clockwise ? 1 : -1)
  end

  def closest_bot
    closest_bot = nil
    sensors.radar.each do |scanned_bot|
      closest_bot ||= scanned_bot
      if scanned_bot.distance < closest_bot.distance
        closest_bot = scanned_bot
      end
    end
    closest_bot
  end
end
