require_relative '../path'
require_relative '../metadata'

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
        Path.new(world, **kwargs)
      end

      # Create a path with a single subpath
      # @param points [Array<Draught::Point>] the points for the subpath
      # @param metadata [Draught::Metadata::Instance] the Path's metadata
      def simple(points:, metadata: nil)
        Path.new(world, points: points, metadata: metadata)
      end

      def build(&block)
        PathDSL.build(world, block)
      end

      def connect(*paths, metadata: nil)
        paths = paths.reject(&:empty?)
        path_metadata = metadata
        build {
          metadata(path_metadata) if !path_metadata.nil?
          points paths.shift
          paths.inject(last_point) { |point, path|
            translation = world.vector.translation_between(path.first, point)
            points path.translate(translation)[1..-1]
            last_point
          }
        }
      end

      class PathDSL
        def self.build(world, block)
          dsl = new(world)
          dsl.instance_eval(&block)
          dsl.send(:build_path_instance)
        end

        attr_reader :world, :path_points
        private :path_points

        # @param world [Draught::World] the World
        def initialize(world)
          @world = world
          @path_points = []
          @metadata = Draught::Metadata::Instance.new
        end

        # convenience Point creator
        #
        # @param x [Number] the X co-ord
        # @param y [Number] the Y co-ord
        # @return [Draught::Point] the resulting Point
        def p(x, y)
          world.point.new(x, y)
        end

        # convenience degrees-to-radians converter
        #
        # @param degrees [Number] the angle in Degrees
        # @return [Number] the angle in Radians
        def deg_to_rad(degrees)
          degrees * (Math::PI/180)
        end

        # Add points to the Path
        #
        # @param points_or_Paths [Array<Draught::Point, Draught::Path>]
        def points(*points_or_paths)
          points = points_or_paths.flat_map { |point_or_path|
            case point_or_path
            when Draught::Pathlike
              point_or_path.points
            else
              point_or_path
            end
          }
          path_points.append(*points)
        end

        # Returns the last Point added
        def last_point
          path_points.last
        end

        # Set the Path's complete metadata
        #
        # @overload metadata(metadata)
        #   uses +metadata+ on the Path
        #   @param metadata [Draught::Metadata::Instance] the {Metadata::Instance} to use
        # @overload metadata(style:, annotation:, name:)
        #   Construct a {Metadata::Instance} using the kwargs
        #   @param style [Draught::Style, Hash[String]] the {Style} for the metadata, either as a {Style} instance or as a hash of the kwargs
        #   @param annotation [Array[String]] Annotations for the metadata
        #   @param name [String] the metadata name
        def metadata(instance = nil, **kwargs)
          kwargs[:style] = style_from_metadata_args(kwargs[:style]) if kwargs.has_key?(:style)

          @metadata = set_via_instance_or_kwargs(Draught::Metadata::Instance, instance, kwargs)
        end

        # Set the Path's metadata Style
        #
        # @overload style(style)
        #   uses +style+ on the Path
        #   @param style [Draught::Style] the {Style} to use
        # @overload style(**kwargs)
        #   Construct a {Style} using the kwargs
        #   @param kwargs [Hash[String]] the kwargs for the Style
        def style(instance = nil, **kwargs)
          @metadata = @metadata.with_style(set_via_instance_or_kwargs(Draught::Style, instance, kwargs))
        end

        # Set the Path's metadata annotation
        #
        # @param annotations [Array<String>] the annotations to use
        def annotation(*annotations)
          @metadata = @metadata.with_annotation(annotations.flat_map { |annotation|
            annotation.respond_to?(:each) ? annotation.each.to_a : annotation
          })
        end

        # Set the Path's metadata name
        #
        # @param name [String] the name to use
        def name(name)
          @metadata = @metadata.with_name(name)
        end

        protected

        def build_path_instance
          Draught::Path.new(world, metadata: @metadata, points: path_points)
        end

        private

        def set_via_instance_or_kwargs(klass, instance, kwargs)
          if !instance.nil? && !instance.is_a?(klass)
            raise ArgumentError, "instance must be a #{klass.name} if present"
          end

          instance.nil? ? klass.new(**kwargs) : instance
        end

        def style_from_metadata_args(style_args)
          case style_args
          when Hash
            set_via_instance_or_kwargs(Draught::Style, nil, style_args)
          else
            set_via_instance_or_kwargs(Draught::Style, style_args, nil)
          end
        end
      end
    end
  end
end
