require_relative './approximately'

module Draught
  class ApproximateRange
    attr_reader :begin, :end

    def initialize(range)
      @begin = Approximately.new(range.begin)
      @end = Approximately.new(range.end)
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
