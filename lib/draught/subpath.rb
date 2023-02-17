require 'forwardable'
require_relative './boxlike'
require_relative './pathlike'
require_relative './extent'

module Draught
  # A Subpath represents a distinct, connected, series of point-like items in a
  # Path.
  class Subpath
    include Boxlike
    include Extent::InstanceMethods

    attr_reader :world, :points
    # @!attribute [r] world
    #   @return [World] the World
    # @!attribute [r] points
    #   @return [Array<Pointlike>] the Pointlikes that make up the subpath

    # @param world [World] the world
    # @param points [Array<Draught::Point>] the points of the Subpath
    def initialize(world, points: [])
      @world = world
      @points = points.dup.freeze
    end

    def <<(point)
      append([point])
    end

    def append(subpaths_or_points)
      new_instance_with_added_points { |current_points|
        subpaths_or_points.inject(current_points) { |appended_points, point_or_path|
          appended_points.append(*point_or_path.points)
        }
      }
    end

    def prepend(subpaths_or_points)
      new_instance_with_added_points { |current_points|
        subpaths_or_points.inject(current_points) { |prepended_points, point_or_path|
          prepended_points.prepend(*point_or_path.points)
        }
      }
    end

    def [](index_start_or_range, length = nil)
      if length.nil?
        case index_start_or_range
        when Range
          new_instance_with_points(points[index_start_or_range])
        when Numeric
          points[index_start_or_range]
        else
          raise TypeError, "requires a Range or Numeric in single-arg form"
        end
      else
        new_instance_with_points(points[index_start_or_range, length])
      end
    end

    def number_of_points
      points.length
    end

    def first
      points.first
    end

    def last
      points.last
    end

    def empty?
      points.empty?
    end

    def ==(other)
      return false if number_of_points != other.number_of_points
      points.zip(other.points).all? { |a, b| a == b }
    end

    def extent
      @extent ||= Extent.new(world, items: points)
    end

    def translate(vector)
      new_instance_with_points(points.map { |p| p.translate(vector) })
    end

    def transform(transformer)
      new_instance_with_points(points.map { |p| p.transform(transformer) })
    end

    def pretty_print(q)
      q.group(1, '(', ')') do
        q.seplist(points, ->() { q.breakable }) do |pointish|
          q.pp pointish
        end
      end
    end

    def subpaths
      [self]
    end

    private

    def new_instance_with_points(points)
      self.class.new(world, points: points)
    end

    def new_instance_with_added_points
      new_points = points.dup
      yield(new_points)
      new_instance_with_points(new_points)
    end
  end
end
