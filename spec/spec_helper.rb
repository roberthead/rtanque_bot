require 'rtanque'

ARENA_HEIGHT = 400
ARENA_WIDTH = 400

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.expect_with :rspec do |c|
    # disable the `should` syntax
    # c.syntax = :expect
  end

  config.before(:all) do
    @arena = RTanque::Arena.new(ARENA_WIDTH, ARENA_HEIGHT)
    RTanque::Configuration.config do
      raise_brain_tick_errors false # errors should be correctly captured
    end
  end

  module BrainHelper
    def on_brain_tick!(brain_klass, &block)
      Class.new(brain_klass).tap do |test_brain|
        test_brain.send(:define_method, :tick!, &block)
      end
    end

    def brain_bot(brain_klass, &tick)
      RTanque::Bot.new(@arena, on_brain_tick!(brain_klass, &tick))
    end
  end
  config.include BrainHelper

  module BotHelper
    def mockbot(x = 0, y = 0, name = 'testbot')
      double('bot', :position => RTanque::Point.new(x, y, @arena), :name => name, :arena => @arena)
    end
  end

  config.include BotHelper
end
