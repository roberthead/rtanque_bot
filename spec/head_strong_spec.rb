require 'spec_helper'
require_relative '../bots/head_strong'

describe HeadStrong do
  describe "#distance_from_wall" do
    let(:brain_tick_lambda) { lambda { } }
    let(:bot) { brain_bot(HeadStrong, &brain_tick_lambda) }

    context "in a certain position" do
      let(:x) { 10 }
      let(:y) { 20 }

      it "accepts a wall and returns the distance" do
        bot.brain.tick(RTanque::Bot::Sensors.new(0, 50, 0, RTanque::Point.new(x, y, @arena), 0, 0, 0, 0))

        bot.brain.distance_from_wall(:top).should == ARENA_HEIGHT - y
        bot.brain.distance_from_wall(:bottom).should == y
        bot.brain.distance_from_wall(:right).should == ARENA_HEIGHT - x
        bot.brain.distance_from_wall(:left).should == x
      end
    end
  end
end
