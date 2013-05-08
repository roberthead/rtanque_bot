class HeadStrong < RTanque::Bot::Brain
  NAME = 'HeadStrong'
  include RTanque::Bot::BrainHelper

  def tick!
    ## main logic goes here

    # use self.sensors to detect things
    # See http://rubydoc.info/github/awilliams/RTanque/master/RTanque/Bot/Sensors

    # use self.command to control tank
    # See http://rubydoc.info/github/awilliams/RTanque/master/RTanque/Bot/Command

    # self.arena contains the dimensions of the arena
    # See http://rubydoc.info/github/awilliams/RTanque/master/frames/RTanque/Arena
  end

  def distance_from_wall(wall)
    case wall.to_sym
    when :top
      sensors.position.y
    when :bottom
      arena.height - sensors.position.y
    when :left
      sensors.position.x
    when :right
      arena.width - sensors.position.x
    end
  end
end
