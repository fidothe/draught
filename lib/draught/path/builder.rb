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
        Path.new(world, subpaths: [Draught::Subpath.new(world, points: points)], metadata: metadata)
      end

      def build(&block)
        PathDSL.build(world, block)
      end

      def connect(*paths, metadata: nil)
        paths = paths.reject(&:empty?)
        raise ArgumentError, "Cannot connect Paths which contain more than one Subpath" if paths.any? { |path| path.subpaths.length > 1 }
        subpaths = paths.map { |path| path.subpaths.first }
        path_metadata = metadata
        build {
          metadata(path_metadata) if !path_metadata.nil?
          points subpaths.shift
          subpaths.inject(last_point) { |point, subpath|
            translation = world.vector.translation_between(subpath.first, point)
            points subpath.translate(translation)[1..-1]
            last_point
          }
        }
      end

      module SubpathDSLMethods
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

        # Add points to the Subpath
        #
        # @param points_or_subpaths [Array<Draught::Point, Draught::Subpath, Draught::Path>]
        def points(*points_or_paths_or_subpaths)
          points = points_or_paths_or_subpaths.flat_map { |point_or_path_or_subpath|
            case point_or_path_or_subpath
            when Draught::Subpath
              point_or_path_or_subpath.points
            when Draught::Pathlike
              raise ArgumentError, "Can't add points from a path with multiple subpaths to a new subpath" if point_or_path_or_subpath.number_of_subpaths > 1
              point_or_path_or_subpath.subpaths.first.points
            else
              point_or_path_or_subpath
            end
          }
          subpath_points.append(*points)
        end

        # Returns the last Point added
        def last_point
          subpath_points.last
        end

        private

        # @return [Array<Draught::Point>]
        def subpath_points
          raise NotImplementedError, "You need to provide an array to put the points in"
        end
      end

      class PathDSL
        include SubpathDSLMethods

        def self.build(world, block)
          dsl = new(world)
          dsl.instance_eval(&block)
          dsl.send(:build_path_instance)
        end

        attr_reader :world, :subpath_points
        private :subpath_points

        # @param world [Draught::World] the World
        def initialize(world)
          @world = world
          @subpath_points = []
          @subpaths = []
          @metadata = Draught::Metadata::Instance.new
        end

        # Add a Subpath to the Path
        def subpath(&block)
          dsl = SubpathDSL.new(world)
          dsl.instance_eval(&block)
          @subpaths.append(dsl.send(:build_subpath_instance))
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
          @subpaths.prepend(Draught::Subpath.new(world, points: subpath_points))
          Draught::Path.new(world, metadata: @metadata, subpaths: @subpaths.reject { |subpath| subpath.empty? })
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

      class SubpathDSL
        include SubpathDSLMethods

        attr_reader :world, :subpath_points
        private :subpath_points

        # @param world [Draught::World] the World
        def initialize(world)
          @world = world
          @subpath_points = []
        end

        protected

        def build_subpath_instance
          Draught::Subpath.new(world, points: subpath_points)
        end
      end
    end
  end
end
