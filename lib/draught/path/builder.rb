require_relative '../path'

module Draught
  class Path
    # Builds new paths, and provides a simple method to build a path from a series
    # of append operations
    class Builder
      attr_reader :world

      def initialize(world)
        @world = world
      end

      def new(**kwargs)
        Path.new(world, kwargs)
      end

      def build(**kwargs)
        builder = Builder.new(new(**kwargs))
        yield(builder)
        builder.path
      end

      def connect(*paths, **kwargs)
        paths = paths.reject(&:empty?)
        build(**kwargs) { |p|
          p << paths.shift
          paths.inject(p.last) { |point, path|
            translation = world.vector.translation_between(path.first, point)
            p << path.translate(translation)[1..-1]
            p.last
          }
        }
      end

      private

      class Builder
        attr_reader :path

        def initialize(path)
          @path = path
        end

        def <<(path_or_point)
          @path = path << path_or_point
          self
        end

        def last
          path.last
        end
      end
    end
  end
end
