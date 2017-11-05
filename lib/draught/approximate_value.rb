module Draught
  class ApproximateValue
    DEFAULT_PRECISION = 6
    DEFAULT_DELTA = 0.000001
    HIGHEST_SANE_DECIMAL_PLACES = 16
    TRAILING_ZEROES = /0*$/

    class << self
      def with_delta(value, delta)
        precision = TRAILING_ZEROES.match(decimals(delta)).begin(0)
        new(value, delta, precision)
      end

      def with_precision(value, precision)
        delta = 1 * (10 ** -precision)
        new(value, delta, precision)
      end

      private

      def decimals(delta)
        format_precision = HIGHEST_SANE_DECIMAL_PLACES - delta.to_int.to_s.length
        Kernel.sprintf("%.#{format_precision}f", delta).split('.').last
      end
    end

    attr_reader :value, :delta, :precision

    def initialize(value, delta = DEFAULT_DELTA, precision = DEFAULT_PRECISION)
      @value = value
      @delta = delta
      @precision = precision
    end

    def is_approximately?(other)
      (value - other).abs.round(precision) <= delta
    end

    def <=>(other)
      return 0 if is_approximately?(other)
      value <=> other
    end
  end
end
