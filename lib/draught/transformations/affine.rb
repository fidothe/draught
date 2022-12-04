require_relative 'common'
require_relative '../point'

module Draught
  module Transformations
    class Affine
      include Common

      attr_reader :transformation_matrix

      def initialize(transformation_matrix)
        @transformation_matrix = transformation_matrix
      end

      def call(point, world)
        world.point.from_matrix(transformation_matrix * point.to_matrix)
      end

      def affine?
        true
      end

      def ==(other)
        other.respond_to?(:transformation_matrix) && other.transformation_matrix == transformation_matrix
      end

      def coalesce(other)
        raise TypeError, "other must be a matrix-based Affine transform" unless other.affine?
        self.class.new(other.transformation_matrix * self.transformation_matrix)
      end
    end
  end
end
