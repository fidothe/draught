require_relative './approximate_value'

module Draught
  class Approximately
    def self.equal?(v1, v2, delta = ApproximateValue::DEFAULT_DELTA)
      ApproximateValue.with_delta(v1, delta).is_approximately?(v2)
    end
  end
end
