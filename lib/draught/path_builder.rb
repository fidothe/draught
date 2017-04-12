require_relative 'path'

module Draught
  class PathBuilder
    def self.build
      builder = new
      yield(builder)
      builder.send(:path)
    end

    def self.connect(*paths)
      build { |p|
        p << paths[0]
        paths[1..-1].inject(p.last) { |point, path|
          translation = Vector.translation_between(path.first, point)
          p << path.translate(translation)
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
