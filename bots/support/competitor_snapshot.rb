class CompetitorSnapshot
  attr_reader :reflection, :tick_index, :position

  def initialize(tracking_bot, reflection, tick_index)
    @tick_index = tick_index
    @reflection = reflection
    @position = computed_position(tracking_bot)
  end

  def computed_position(tracking_bot)
    x = (tracking_bot.sensors.position.x + (Math.sin(reflection.heading) * reflection.distance)).round(10)
    y = (tracking_bot.sensors.position.y + (Math.cos(reflection.heading) * reflection.distance)).round(10)
    RTanque::Point.new(x, y, tracking_bot.arena)
  end

  def on_top_wall?
    position.on_top_wall?
  end

  def on_right_wall?
    position.on_right_wall?
  end

  def on_bottom_wall?
    position.on_bottom_wall?
  end

  def on_left_wall?
    position.on_left_wall?
  end

  def on_wall?
    position.on_wall?
  end

  def name
    reflection.name
  end
end
