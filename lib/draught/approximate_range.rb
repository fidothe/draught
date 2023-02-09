require_relative './approximate_value'

module Draught
  class ApproximateRange
    attr_reader :begin, :end

    def initialize(range, delta = ApproximateValue::DEFAULT_DELTA)
      @begin = ApproximateValue.with_delta(range.begin, delta)
      @end = ApproximateValue.with_delta(range.end, delta)
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
