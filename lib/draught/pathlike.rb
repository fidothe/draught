require_relative 'metadata'

module Draught
  module Pathlike
    include Metadata::Methods

    def subpaths
      raise NotImplementedError, "Pathlike objects must implement #subpaths to return any Subpaths they contain"
    end

    def translate(vector)
      raise NotImplementedError, "Pathlike objects must implement translation by Vector"
    end

    def transform(transformation)
      raise NotImplementedError, "Pathlike objects must implement transformation by Affine transform or point-taking lambda"
    end

    def [](index_start_or_range, length = nil)
      raise NotImplementedError, "Pathlike objects must implement [] access on their points, returning a new instance"
    end

    def number_of_subpaths
      subpaths.length
    end

    def first
      subpaths.first
    end

    def last
      subpaths.last
    end

    def empty?
      subpaths.empty? || subpaths.all? { |subpath| subpath.empty? }
    end

    def ==(other)
      return false if number_of_subpaths != other.number_of_subpaths
      subpaths.zip(other.subpaths).all? { |a, b| a == b }
    end

    def paths
      []
    end

    def containers
      []
    end

    def box_type
      [:path]
    end
  end
end
