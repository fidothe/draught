require 'svg_fixture_helper'

module IntersectionHelper
  class Harness
    attr_reader :checker, :fixture_name, :segment_1_id, :segment_2_id

    def initialize(checker, fixture_name, segment_1_id, segment_2_id)
      @checker, @fixture_name, @segment_1_id, @segment_2_id = checker, fixture_name, segment_1_id, segment_2_id
    end

    def world
      @world ||= checker.world
    end

    def id_patterns
      @id_patterns ||= {expected: /^expected$/, segment_1: Regexp.new("^#{segment_1_id}$"), segment_2: Regexp.new("^#{segment_2_id}$")}
    end

    def loader
      patterns = id_patterns
      mapper = method(:pathlike_mapper)
      @loader ||= SVGFixtureHelper::FixtureLoader.new(world, fixture_name).call {
          fetch **patterns
          map_paths &mapper
        }
    end

    def segment_1
      @segment_1 ||= loader.found[:segment_1]
    end

    def segment_2
      @segment_2 ||= loader.found[:segment_2]
    end

    def expected
      @expected ||= loader.found[:expected].points
    end

    def actual
      @actual ||= checker.check(segment_1, segment_2)
    end

    def sorted_expected
      @sorted_expected ||= expected.sort(&sort)
    end

    def sorted_actual
      @sorted_actual ||= actual.sort(&sort)
    end

    private

    def sort
      ->(a, b) {
        x = a.x <=> b.x
        return x if x != 0
        a.y <=> b.y
      }
    end

    def path_is_line?(path)
      path.points.all? { |point| point.point_type == :point }
    end

    def path_is_curve?(path)
      !path_is_line?(path)
    end

    def pathlike_mapper(world, pathlike)
      pathlike.name == 'expected' ? pathlike : build_segment(pathlike)
    end

    def build_segment(path)
      builder = path_is_curve?(path) ? world.curve_segment : world.line_segment
      builder.from_path(path)
    end
  end
end

RSpec::Matchers.define :have_intersecting do |segment_1_id, segment_2_id|
  match do |fixture_name|
    intersection_harness = IntersectionHelper::Harness.new(subject, fixture_name, segment_1_id, segment_2_id)
    @actual_points = intersection_harness.sorted_actual
    @expected_points = intersection_harness.sorted_expected
    @expected_length = @expected_points.length
    @actual_points.length == @expected_length && @actual_points.zip(@expected_points).all? { |actual_point, expected_point|
      actual_point == expected_point
    }
  end

  def expected
    @expected_points.map(&:to_s).join(", ")
  end

  def actual
    @actual_points.map(&:to_s).join(", ")
  end

  description { "find that '#{segment_1_id}' intersects '#{segment_2_id}' #{@expected_length} times" }

  diffable
end
