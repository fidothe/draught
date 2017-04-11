require_relative './composition'

module Draught
  module Transformations
    class Composer
      def self.compose(*transforms)
        new(transforms).composition
      end

      attr_reader :transforms

      def initialize(transforms)
        @transforms = transforms
      end

      def composition
        Composition.new(coalesced_transforms)
      end

      def coalesced_transforms
        return [] if transforms.empty?
        start_transforms = flattened_transforms
        finished = start_transforms.shift(1)
        return finished if start_transforms.empty?

        start_transforms.each do |next_transform|
          coalesce_pair(finished.pop, next_transform).each do |coalesced_transform|
            finished << coalesced_transform
          end
        end
        finished
      end

      def flattened_transforms
        transforms.flat_map { |transform|
          transform.to_transform.transforms
        }
      end

      private

      def coalesce_pair(first, second)
        begin
          [first.coalesce(second)]
        rescue TypeError
          [first, second]
        end
      end
    end
  end
end
