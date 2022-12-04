module Draught
  class Tolerance
    DEFAULT_PRECISION = 6
    DEFAULT_DELTA = 0.000001
    HIGHEST_SANE_DECIMAL_PLACES = 16
    TRAILING_ZEROES = /0*$/

    class << self
      def with_delta(delta)
        precision = TRAILING_ZEROES.match(decimals(delta)).begin(0)
        new(delta, precision)
      end

      def with_precision(precision)
        delta = 1 * (10 ** -precision)
        new(delta, precision)
      end

      private

      def decimals(delta)
        format_precision = HIGHEST_SANE_DECIMAL_PLACES - delta.to_int.to_s.length
        Kernel.sprintf("%.#{format_precision}f", delta).split('.').last
      end
    end

    attr_reader :delta, :precision

    def initialize(delta = DEFAULT_DELTA, precision = DEFAULT_PRECISION)
      @delta = delta
      @precision = precision
    end

    def within?(first, second)
      (first - second).abs.round(precision) <= delta
    end

    def outside?(first, second)
      !within?(first, second)
    end

    DEFAULT = new()
  end
end
