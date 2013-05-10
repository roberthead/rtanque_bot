require 'spec_helper'
require_relative '../bots/support/competitor_snapshot'

describe CompetitorSnapshot do
  let(:brain_tick_lambda) { lambda { } }
  let(:bot) { brain_bot(HeadStrong, &brain_tick_lambda) }
  subject(:snapshot) { CompetitorSnapshot.new(bot, reflection, 0) }

  context "give a tank ten units to the north" do
    let(:reflection) { RTanque::Bot::Radar::Reflection.new(0, 10, 'tank') }

    its(:position) { should == RTanque::Point.new(0, 10, bot.arena) }

    it { should be_on_left_wall }

    it { should_not be_on_top_wall }
    it { should_not be_on_right_wall }
    it { should_not be_on_bottom_wall }
  end
end
