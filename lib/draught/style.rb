module Draught
  class Style
    attr_reader :stroke_color, :stroke_width, :fill

    def initialize(args = {})
      @stroke_color = args.fetch(:stroke_color, nil)
      @stroke_width = args.fetch(:stroke_width, nil)
      @fill = args.fetch(:fill, nil)
    end
  end
end
