require_relative 'path'

module Draught
  class PathBuilder
    def self.build
      builder = new
      yield(builder)
      builder.send(:path)
    end

    def self.connect(*paths_and_points)
      build { |p|
        p << paths_and_points[0]
        paths_and_points[1..-1].inject(p.last) { |point, path_or_point|
          p << path_or_point.translate(point)
          p.last
        }
      }
    end

    attr_reader :path
    private :path

    def initialize
      @path = Path.new
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
