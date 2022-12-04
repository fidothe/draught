require_relative './value_with_tolerance'

module Draught
  class RangeWithTolerance
    attr_reader :begin, :end, :tolerance

    def initialize(range, tolerance)
      @begin = ValueWithTolerance.new(range.begin, tolerance)
      @end = ValueWithTolerance.new(range.end, tolerance)
      @tolerance = tolerance
    end

    def include?(value)
      gte_begin(value) && lte_end(value)
    end

    private

    def gte_begin(value)
      (self.begin <=> value) <= 0
    end

    def lte_end(value)
      (self.end <=> value) >= 0
    end
  end
end
