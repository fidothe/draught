require_relative './common'
require_relative '../point'

module Draught
  module Transformations
    class Proclike
      include Common

      attr_reader :proclike

      def initialize(proclike)
        @proclike = proclike
      end

      def call(point)
        point_from_tuple_or_point(proclike.call(point))
      end

      def affine?
        false
      end

      def ==(other)
        other.respond_to?(:proclike) && proclike == other.proclike
      end

      def flattened_transforms
        [self]
      end

      def coalesce(other)
        raise TypeError, "non-Affine transforms cannot be coalesced"
      end

      private

      def point_from_tuple_or_point(tuple_or_point)
        return Point.new(*tuple_or_point) if tuple_or_point.respond_to?(:each)
        tuple_or_point
      end
    end
  end
end
