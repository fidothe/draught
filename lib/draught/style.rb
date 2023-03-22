module Draught
  class Style
    attr_reader :stroke_color, :stroke_width, :fill

    def initialize(stroke_color: nil, stroke_width: nil, fill: nil)
      @stroke_color, @stroke_width, @fill = stroke_color, stroke_width, fill
    end

    def ==(other)
      self.class === other && [:stroke_color, :stroke_width, :fill].all? { |meth| self.public_send(meth) == other.public_send(meth) }
    end
  end
end
