require_relative 'support/competitor_snapshot'
require_relative 'support/competitor'

class Tracker < RTanque::Bot::Brain
  NAME = 'Tracker'
  include RTanque::Bot::BrainHelper

  attr_accessor :competitors
  attr_reader :current_tick_index

  def initialize(*args)
    self.competitors = []
    super
  end

  def tick!
    @current_tick_index = self.sensors.ticks
    track_competitors
    if best_target
      new_heading =
        RTanque::Heading.new_between_points(
          self.sensors.position,
          best_target.position_to_fire_at(current_tick_index)
        )
      command.turret_heading = new_heading
      command.radar_heading = new_heading
      command.fire(2)
    else
      new_heading = sensors.turret_heading - 0.1
      command.radar_heading = new_heading
      command.turret_heading = new_heading
    end
    command.speed = MAX_BOT_SPEED
    command.heading = sensors.heading + 0.1
    if current_tick_index % 50 == 0
      puts
      s = competitors.map do |tank|
        "#{tank.name} at [#{tank.position.x.round(2)}, #{tank.position.y.round(2)}] (#{tank.distance.round(2)} clicks away @ #{tank.heading.radians.round(2)} radians), speed: #{tank.speed.round(2)}"
      end
      puts s.join("\n")
    elsif current_tick_index % 5000 == 0
      raise "done"
    end
  end

  # maneuver states:
  # hunt
  # approach (spiral in until at optimal distance)
  # circle_strafing
  # - target

  # actions:
  # lock on target

  def best_target
    far_enough = competitors.select do |competitor|
      competitor.projected_position_at(current_tick_index).distance(self.sensors.position) >= RTanque::Bot::Turret::LENGTH
    end
    far_enough.sort_by do |competitor|
      competitor.projected_position_at(current_tick_index).distance(self.sensors.position) +
        (competitor.name == NAME ? 1000 : 0)
    end.first
  end

  def track_competitors
    sensors.radar.each do |reflection|
      snapshot = CompetitorSnapshot.new(self, reflection, current_tick_index)
      known_competitor = competitor_matching_snapshot(snapshot)
      if known_competitor
        known_competitor.snapshots << snapshot
      else
        self.competitors << Competitor.new(self.arena, snapshot)
      end
    end
    self.competitors.delete_if do |competitor|
      competitor.speed > RTanque::Bot::BrainHelper::MAX_BOT_SPEED ||
        current_tick_index - competitor.snapshots.last.tick_index > 50
    end
  end

  def competitor_matching_snapshot(snapshot)
    self.competitors.select do |competitor|
      competitor.name == snapshot.name && competitor.could_be_at_position_at?(snapshot.position, self.sensors.ticks)
    end.sort_by do |competitor|
      competitor.projected_position_at(self.sensors.ticks).distance(snapshot.position)
    end.first
  end
end
