module Draught
  module Transformations
    class Composer
      def self.coalesced(*transforms)
        new(*transforms).coalesce
      end

      attr_reader :transforms

      def initialize(*transforms)
        @transforms = transforms
      end

      def call(point)
        transforms.inject(point) { |point, transform| transform.call(point) }
      end

      def ==(other)
        other.respond_to?(:coalesce) && other.transforms == transforms
      end

      def coalesce
        self.class.new(*coalesced_transforms)
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
          transform.flattened_transforms
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
