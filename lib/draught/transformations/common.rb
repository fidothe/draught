require_relative './composer'

module Draught
  module Transformations
    module Common
      def call(point)
        raise NotImplementedError, "Classes including Transformations::Common must implement #call, taking a Point and returning a new, transformed, Point"
      end

      def affine?
        raise NotImplementedError, "Classes including Transformations::Common must implement #affine?"
      end

      def to_transform
        self
      end

      def flattened_transforms
        [self]
      end

      def compose(other)
        Composer.coalesced(other, self)
      end
    end
  end
end
