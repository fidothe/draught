require_relative './path'
require_relative './point'

module Draught
  class Line
    class << self
      def horizontal(width)
        Path.new([Point::ZERO, Point.new(width, 0)])
      end

      def vertical(height)
        Path.new([Point::ZERO, Point.new(0, height)])
      end
    end
  end
end
