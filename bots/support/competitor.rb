class Competitor
  attr_accessor :arena, :snapshots

  def initialize(arena, snapshot)
    self.arena = arena
    self.snapshots = [snapshot]
  end

  def could_be_at_position_at?(position, tick_index)
    snapshots.last &&
      snapshots.last.position.distance(position) <= RTanque::Bot::BrainHelper::MAX_BOT_SPEED * (tick_index - snapshots.last.tick_index).abs + 0.1
  end

  def name
    snapshots.first.reflection.name
  end

  def direction
    if snapshots.length > 1
      RTanque::Heading.new_between_points(snapshots[-2].position, snapshots[-1].position)
    else
      0
    end
  end

  def speed
    if snapshots.length > 1
      snapshots[-2].position.distance(snapshots[-1].position)
    else
      0
    end
  end

  def position
    snapshots.last.position
  end

  def distance
    snapshots.last.reflection.distance
  end

  def heading
    snapshots.last.reflection.heading
  end

  def projected_position_at(tick_index)
    distance_traveled = speed * (tick_index - snapshots.last.tick_index)
    x = (position.x + (Math.sin(direction) * distance_traveled)).round(10)
    y = (position.y + (Math.cos(direction) * distance_traveled)).round(10)
    RTanque::Point.new(x, y, self.arena) { |point| point.bind_to_arena }
  end

  def position_to_fire_at(current_tick_index)
    projected_position_at(current_tick_index + ticks_for_shell_to_reach)
  end

  def ticks_for_shell_to_reach
    distance / 10
  end
end
