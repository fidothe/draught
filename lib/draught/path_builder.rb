require_relative 'path'

module Draught
  class PathBuilder
    def self.build
      builder = new
      yield(builder)
      builder.send(:path)
    end

    attr_reader :path
    private :path

    def initialize
      @path = Path.new
    end

    def <<(path_or_point)
      @path = path << path_or_point
    end

    def last
      path.last
    end
  end
end
