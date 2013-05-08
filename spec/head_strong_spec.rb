require 'spec_helper'
require_relative '../bots/head_strong'

describe HeadStrong do
  describe "#distance_from_wall" do
    let(:brain_tick_lambda) { lambda { } }
    let(:bot) { brain_bot(&brain_tick_lambda) }

    context "in a certain position" do
      it "accepts a wall and returns the distance" do
        bot.brain.tick(RTanque::Bot::Sensors.new(0, 50, 0, RTanque::Point.new(10, 20, @arena), 0, 0, 0, 0))

        bot.brain.distance_from_wall(:top).should == 80
        bot.brain.distance_from_wall(:bottom).should == 20
        bot.brain.distance_from_wall(:right).should == 90
        bot.brain.distance_from_wall(:left).should == 10
      end
    end
  end
end
