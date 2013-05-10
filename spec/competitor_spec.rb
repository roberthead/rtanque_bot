require 'spec_helper'
require_relative '../bots/support/competitor'

describe Competitor do
  let(:brain_tick_lambda) { lambda { } }
  let(:bot) { brain_bot(HeadStrong, &brain_tick_lambda) }

  context "with just the initial snapshot" do
    let(:reflection) { RTanque::Bot::Radar::Reflection.new(0, 10, 'tank') }
    let(:snapshot) { CompetitorSnapshot.new(bot, reflection, 0) }
    subject(:competitor) { Competitor.new(bot.arena, snapshot) }

    its(:position) { should == snapshot.position }
    its(:speed) { should == 0 }
    its(:direction) { should == 0 }
    its(:name) { should == 'tank' }

    it "is not projected to go anywhere" do
      [0, 1, 5, 99].each do |ticks|
        competitor.projected_position_at(ticks).should == snapshot.position
      end
    end

    it "knowns where it could be" do
      competitor.could_be_at_position_at?(RTanque::Point.new(10, 10), 2).should be_false
      competitor.could_be_at_position_at?(RTanque::Point.new(10, 10), 10).should be_true
      competitor.could_be_at_position_at?(RTanque::Point.new(30, 30), 2).should be_false
      competitor.could_be_at_position_at?(RTanque::Point.new(30, 10), 10).should be_true
    end
  end

  context "almost to the wall" do
    let(:reflection) { RTanque::Bot::Radar::Reflection.new(1.0 * RTanque::Heading::EIGHTH_ANGLE, 5, 'tank') }
    let(:initial_snapshot) { CompetitorSnapshot.new(bot, reflection, 0) }
    subject(:competitor) { Competitor.new(bot.arena, initial_snapshot) }

    let(:next_reflection) { RTanque::Bot::Radar::Reflection.new(1.5 * RTanque::Heading::EIGHTH_ANGLE, 4, 'tank') }

    before do
      competitor.snapshots << CompetitorSnapshot.new(bot, next_reflection, 1)
    end

    specify { competitor.position.x.should be_within(0.1).of(3.7) }
    specify { competitor.position.y.should be_within(0.1).of(1.5) }

    its(:speed) { should be_within(0.1).of(2.0) }
    its(:direction) { should be_within(RTanque::Heading::EIGHTH_ANGLE / 2).of(RTanque::Heading::EIGHTH_ANGLE * 3.5) }
    its(:name) { should == 'tank' }

    it "is projected to stop at the wall" do
      competitor.projected_position_at(0).should == competitor.snapshots[0].position
      competitor.projected_position_at(1).should == competitor.snapshots[1].position
      competitor.projected_position_at(2).x.should > competitor.snapshots[1].position.x
      competitor.projected_position_at(2).y.should == 0.0
    end

    it "knowns where it could be" do
      competitor.could_be_at_position_at?(RTanque::Point.new(10, 10), 2).should be_false
      competitor.could_be_at_position_at?(RTanque::Point.new(10, 10), 10).should be_true
    end
  end
end
