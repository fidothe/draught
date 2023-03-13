require 'svg_fixture_helper'
require 'forwardable'

module IntersectionHelper
  class Harness
    attr_reader :checker, :fixture_name, :input_1_id, :input_2_id, :input_mapper_class

    def initialize(checker, fixture_name, input_1_id, input_2_id, input_mapper_class)
      @checker, @fixture_name, @input_1_id, @input_2_id, @input_mapper_class = checker, fixture_name, input_1_id, input_2_id, input_mapper_class
    end

    def world
      @world ||= checker.world
    end

    def id_patterns
      @id_patterns ||= {expected: /^expected$/, input_1: Regexp.new("^#{input_1_id}$"), input_2: Regexp.new("^#{input_2_id}$")}
    end

    def loader
      patterns = id_patterns
      mapper = method(:pathlike_mapper)
      @loader ||= SVGFixtureHelper::FixtureLoader.new(world, fixture_name).call {
          fetch **patterns
          map_paths &mapper
        }
    end

    def input_1
      @input_1 ||= loader.found[:input_1]
    end

    def input_2
      @input_2 ||= loader.found[:input_2]
    end

    def expected
      @expected ||= loader.found[:expected]
    end

    def actual
      @actual ||= checker.intersections(input_1, input_2)
    end

    def sorted_expected
      @sorted_expected ||= IntersectionPoints.new(expected)
    end

    def sorted_actual
      @sorted_actual ||= IntersectionPoints.new(actual)
    end

    def output_debug_svg(path)
      require 'draught/renderer/svg'
      require 'draught/bounding_box'

      curve_style = Draught::Style.new(stroke_width: '1px', stroke_color: 'black', fill: 'none')
      expected_style = Draught::Style.new(stroke_width: '10px', stroke_color: 'rgb(255,107,1)', fill: 'none')
      actual_style = Draught::Style.new(stroke_width: '1px', stroke_color: 'rgb(2,171,255)', fill: 'none')

      expected_path = world.path.simple(*sorted_expected).with_style(expected_style).with_name('expected')
      actual_path = world.path.simple(*sorted_actual).with_style(actual_style).with_name('actual')
      box = Draught::BoundingBox.new(world, [input_1.with_style(curve_style), input_2.with_style(curve_style), expected_path, actual_path])
      Draught::Renderer::SVG.render_to_file(path, box)
    end

    private

    def input_mapper
      @input_mapper ||= input_mapper_class.new(world)
    end

    def sort
      ->(a, b) {
        x = a.x.round(2) <=> b.x.round(2)
        return x if x != 0
        a.y.round(2) <=> b.y.round(2)
      }
    end

    def pathlike_mapper(world, pathlike)
      pathlike.name == 'expected' ? normalize_expected(pathlike) : input_mapper.map_input(pathlike)
    end

    def build_segment(path)
      builder = path_is_curve?(path) ? world.curve_segment : world.line_segment
      builder.from_path(path)
    end

    # I use Affinity Designer to create the fixtures and it automatically
    # simplifies paths on export, which means that a three-point path which is
    # also a line (like the path for expectec 3-point intersection of a line and
    # a curve) will be turned into a 2-point path. To get around this, I use a
    # cubic point on the path, which prevents it being simplifed, but means this
    # normalization process is required where any cubics get their end point
    # taken and used instead.
    def normalize_expected(pathlike)
      pathlike.points.map { |pointlike|
        case pointlike
        when Draught::CubicBezier
          pointlike.end_point
        else
          pointlike
        end
      }
    end
  end

  class SegmentInputMapper
    attr_reader :world

    def initialize(world)
      @world = world
    end

    def path_is_line?(path)
      path.points.all? { |point| point.point_type == :point }
    end

    def path_is_curve?(path)
      !path_is_line?(path)
    end

    def map_input(path)
      builder = path_is_curve?(path) ? world.curve_segment : world.line_segment
      builder.from_path(path)
    end
  end


  class PathInputMapper
    def initialize(world)
      @world = world
    end

    def map_input(path)
      path
    end
  end

  # This class basically only exists to make diffable output look right
  class IntersectionPoints
    extend Forwardable
    include Enumerable

    attr_reader :points

    def_delegators :points, :"[]", :length, :size

    def initialize(points)
      @points = points.sort(&point_sorter)
    end

    def each(&block)
      points.each(&block)
    end

    def pretty_print(q)
      q.group(1, '[', ']') do
        q.seplist(points, ->() { }) do |pointlike|
          q.breakable
          q.pp pointlike
        end
      end
    end

    private

    def point_sorter
      ->(a, b) {
        x = a.x.round(2) <=> b.x.round(2)
        return x if x != 0
        a.y.round(2) <=> b.y.round(2)
      }
    end
  end

  class IntersectionMatcher
    attr_reader :actual, :expected, :input_1_id, :input_2_id, :input_mapper_class, :fixture_name, :checker
    private :input_1_id, :input_2_id, :input_mapper_class, :fixture_name, :checker

    def initialize(input_1_id, input_2_id)
      @input_1_id, @input_2_id = input_1_id, input_2_id
      @input_mapper_class = SegmentInputMapper
    end

    def matches?(checker)
      @checker = checker

      generate_debug_output if match_failed?

      match_succeeded?
    end

    def actual
      @actual ||= harness.sorted_actual
    end

    def expected
      @expected ||= harness.sorted_expected
    end

    def in(fixture_name)
      @fixture_name = fixture_name
      self
    end

    def as_paths
      @input_mapper_class = PathInputMapper
      self
    end

    def debug_output(path)
      @debug = true
      @debug_output_path = path
      self
    end

    def debug
      @debug = true
      self
    end

    def description
      "find that '#{input_1_id}' intersects '#{input_2_id}' #{@expected_length} times"
    end

    def failure_message
      if !has_correct_number_of_intersections?
        "expected #{expected.length} intersections, got #{actual.length}"
      else
        "expected all #{expected.length} intersection points to match"
      end
    end

    def diffable?
      true
    end

    private

    def harness
      @harness ||= Harness.new(checker, fixture_name, input_1_id, input_2_id, input_mapper_class)
    end

    def has_correct_number_of_intersections?
      actual.length == expected.length
    end

    def points_of_intersection_match?
      actual.zip(expected).all? { |actual_point, expected_point|
        actual_point == expected_point
      }
    end

    def match_succeeded?
      @match_succeeded ||= has_correct_number_of_intersections? && points_of_intersection_match?
    end

    def match_failed?
      !match_succeeded?
    end

    def generate_debug_output
      if @debug
        debug_path = Pathname.new(@debug_output_path || fixture_name)
        debug_path = "#{debug_path.basename(debug_path.extname)}-failure-debug.svg" if @debug_output_path.nil?
        harness.output_debug_svg(debug_path)
      end
    end
  end

  module Matchers
    def find_intersections_of(input_1_id, input_2_id)
      IntersectionMatcher.new(input_1_id, input_2_id)
    end
  end
end
