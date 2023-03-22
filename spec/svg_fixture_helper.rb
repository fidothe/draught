module SVGFixtureHelper
  module Helpers
    def svg_fixture(fixture_name, world = nil, &block)
      if world.nil?
        require 'draught/world'
        world = Draught::World.new
      end
      FixtureLoader.new(world, fixture_name).call(&block)
    end
  end

  class DuplicateFixtureError < StandardError
    attr_reader :duplicate, :file

    def initialize(duplicate, file)
      @duplicate, @file = duplicate, file
    end

    def to_s
      "Path '#{duplicate}' in fixture file #{file} appears more than once"
    end
  end

  module FixtureFinder
    def self.included(base)
      base.send(:attr_reader, :world, :parsed_fixture, :fixture_path, :id_patterns, :result_path_mapper)
    end

    def initialize(world:, parsed_fixture:, fixture_path:, id_patterns:, result_path_mapper:)
      @world, @parsed_fixture, @fixture_path, @id_patterns, @result_path_mapper = world, parsed_fixture, fixture_path, id_patterns, result_path_mapper
      @result = nil
      @matched_ids = []
    end

    def found
      @result ||= find_all(parsed_fixture, {})
    end

    def find_all(boxlike, result = {})
      boxlike.paths.each do |pathlike|
        id_patterns.each do |name, pattern|
          finder(result, pathlike, name, pattern)
        end
      end
      boxlike.paths.each do |pathlike|
        find_all(pathlike, result)
      end
      result
    end

    def finder(result, pathlike, pattern_name, pattern)
      raise NotImplementedError
    end

    def check!(pathlike)
      raise DuplicateFixtureError.new(pathlike.name, fixture_path) if @matched_ids.include?(pathlike.name)
      @matched_ids << pathlike.name
    end
  end

  class FlatFixture
    include FixtureFinder

    def fetch(&block)
      keys = block.parameters[1..].map { |_, key| key }

      block.call(world, *keys.map { |key| found[key] })
    end

    private

    def finder(result, pathlike, pattern_name, pattern)
      match = pattern.match(pathlike.name)
      if !match.nil?
        check!(pathlike)
        (result[pattern_name] ||= {})[pathlike.name] = result_path_mapper.call(world, pathlike)
      end
    end
  end

  class ArrayFixture
    include FixtureFinder

    def each(&block)
      found.each do |name, path|
        block.call(world, path, name)
      end
    end

    private

    def finder(result, pathlike, pattern_name, pattern)
      match = pattern.match(pathlike.name)
      if !match.nil?
        check!(pathlike)
        result[pathlike.name] = result_path_mapper.call(world, pathlike)
      end
    end
  end

  class GroupedFixture
    include FixtureFinder

    def each(&block)
      keys = block.parameters[2..].map { |_, key| key }
      found.each do |group_key, paths|
        block.call(world, group_key, *keys.map { |key| paths[key] })
      end
    end

    private

    def finder(result, pathlike, pattern_name, pattern)
      match = pattern.match(pathlike.name)
      if !match.nil?
        check!(pathlike)
        group = (result[match[1]] ||= {})
        group[pattern_name] = result_path_mapper.call(world, pathlike)
      end
    end
  end

  class FixtureLoader
    attr_reader :world, :fixture_name, :id_patterns

    def initialize(world, fixture_name)
      @world, @fixture_name = world, fixture_name
      @map_paths = ->(world, path) { path }
      @id_patterns = {}
    end

    def fixture_dir
      @fixture_dir ||= Pathname.new(__dir__)/'fixtures'
    end

    def fixture_path
      @fixture_path ||= fixture_dir.join(fixture_name)
    end

    def parsed_fixture
      # postpone requiring until we absolutely have to to avoid a broken SVG
      # parser causing all examples to error out
      require 'draught/parser/svg'
      @parsed_fixture ||= Draught::Parser::SVG.new(world, fixture_path.open('r:utf-8')).parse!
    end

    def fetch_grouped(**id_patterns)
      @fixture_class = GroupedFixture
      @id_patterns = id_patterns
    end

    def fetch(**id_patterns)
      @fixture_class = FlatFixture
      @id_patterns = id_patterns
    end

    def fetch_all(**id_patterns)
      @fixture_class = ArrayFixture
      @id_patterns = id_patterns
    end

    def map_paths(&block)
      @map_paths = block
    end

    def call(&block)
      instance_exec(&block) if block_given?

      raise ArgumentError, "Must call fetch, fetch_all, or fetch_grouped in the svg_fixture block" if @fixture_class.nil?
      @fixture_class.new(world: world, parsed_fixture: parsed_fixture, fixture_path: fixture_path,
        id_patterns: id_patterns, result_path_mapper: @map_paths)
    end
  end
end
