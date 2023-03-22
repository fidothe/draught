require 'svg_fixture_helper'
require 'draught/path_intersection_point'
require 'forwardable'

module IntersectionHelper
  class Harness
    attr_reader :checker, :fixture_name, :input_ids, :input_mapper_class, :expected_mapper

    def initialize(checker, fixture_name, input_ids, input_mapper_class, expected_mapper)
      @checker, @fixture_name, @input_ids, @input_mapper_class, @expected_mapper = checker, fixture_name, input_ids, input_mapper_class, expected_mapper
    end

    def world
      @world ||= checker.world
    end

    def id_patterns
      @id_patterns ||= {"expected" => /^expected/}.merge(input_ids.each_with_index.map { |id, n| ["input_#{n}", Regexp.new("^#{id}$")] }.to_h)
    end

    def loader
      patterns = id_patterns
      @loader ||= SVGFixtureHelper::FixtureLoader.new(world, fixture_name).call {
          fetch **patterns
        }
    end

    def inputs
      @inputs ||= extract_inputs
    end

    def extract_inputs
      loader.found.select { |k, v|
        k.start_with?("input_")
      }.values.flat_map { |name_plus_matches|
        name_plus_matches.values.map(&input_mapper)
      }
    end

    def expected
      @expected ||= loader.found["expected"].flat_map { |name, pathlike|
        expected_mapper.call(pathlike, inputs)
      }
    end

    def actual
      @actual ||= checker.intersections(*inputs)
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

    def normalize_expected(pathlike)
      pathlike.points.map(&:position_point)
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

    def call(path)
      builder = path_is_curve?(path) ? world.curve_segment : world.line_segment
      builder.from_path(path)
    end

    def to_proc
      method(:call).to_proc
    end
  end

  # I use Affinity Designer to create the fixtures and it automatically
  # simplifies paths on export, which means that a three-point path which is
  # also a line (like the path for expected 3-point intersection of a line and
  # a curve) will be turned into a 2-point path. To get around this, I use a
  # cubic point on the path, which prevents it being simplifed, but means this
  # normalization process is required where any cubics get their end point
  # taken and used instead.
  SEGMENT_CHECKER_EXPECTED_MAPPER = ->(pathlike, inputs) {
    pathlike.points.map(&:position_point)
  }

  PATH_CHECKER_EXPECTED_MAPPER = ->(pathlike, inputs) {
    # path name is 'expected_id-1_id-2'
    input_ids = pathlike.name.sub('expected-', '').split('_')
    intersections = pathlike.points.map { |point|
      Draught::PathIntersectionPoint.new(point.world, point.position_point, inputs.select { |pathlike| input_ids.include?(pathlike.name) })
    }
  }

  class PathInputMapper
    def initialize(world)
      @world = world
    end

    def call(path)
      path
    end

    def to_proc
      method(:call).to_proc
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
    attr_reader :input_1_id, :input_2_id, :fixture_name, :checker
    private :input_1_id, :input_2_id, :fixture_name, :checker

    def initialize(input_1_id, input_2_id)
      @input_1_id, @input_2_id = input_1_id, input_2_id
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
      @harness ||= Harness.new(checker, fixture_name, [input_1_id, input_2_id], SegmentInputMapper, SEGMENT_CHECKER_EXPECTED_MAPPER)
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

  class PathIntersectionMatcher < IntersectionMatcher
    attr_reader :input_ids, :fixture_name, :checker
    private :input_ids, :fixture_name, :checker

    def initialize(input_ids)
      @input_ids = input_ids
    end

    def description
      "find that #{input_ids.join(' ')} intersect #{@expected_length} times"
    end

    private

    def harness
      @harness ||= Harness.new(checker, fixture_name, input_ids, PathInputMapper, PATH_CHECKER_EXPECTED_MAPPER)
    end
  end

  module Matchers
    def find_intersections_of(input_1_id, input_2_id)
      IntersectionMatcher.new(input_1_id, input_2_id)
    end

    def find_path_intersections_between(*input_ids)
      PathIntersectionMatcher.new(input_ids)
    end
  end
end
