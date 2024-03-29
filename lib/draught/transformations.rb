require 'matrix'
require_relative 'point'
require_relative 'transformations/affine'
require_relative 'transformations/proclike'
require_relative 'transformations/composer'

module Draught
  module Transformations
    extend self

    MM_TO_PT = 2.8346456692913

    def mm_to_pt
      unit_factor(MM_TO_PT)
    end

    def pt_to_mm
      unit_factor(1/MM_TO_PT)
    end

    def mm_to_dpi(dpi)
      unit_factor(MM_TO_PT * (dpi/72.0))
    end

    def dpi_to_mm(dpi)
      unit_factor(1/(MM_TO_PT * (dpi/72.0)))
    end

    def unit_factor(factor)
      Affine.new(Matrix[
        [factor, 0, 0],
        [0, factor, 0],
        [0, 0, 1]
      ])
    end

    def x_axis_reflect
      Affine.new(Matrix[
        [1,0,0],
        [0,-1,0],
        [0,0,1]
      ])
    end

    def y_axis_reflect
      Affine.new(Matrix[
        [-1,0,0],
        [0,1,0],
        [0,0,1]
      ])
    end

    def xy_axis_reflect
      Composer.compose(x_axis_reflect, y_axis_reflect)
    end

    def scale(factor)
      Transformations::Affine.new(Matrix[
        [factor, 0, 0],
        [0, factor, 0],
        [0, 0, 1]
      ])
    end

    def rotate(radians)
      cos = Math.cos(radians)
      sin = Math.sin(radians)
      Transformations::Affine.new(Matrix[
        [cos, -sin, 0],
        [sin, cos, 0],
        [0, 0, 1]
      ])
    end

    def round_to_n_decimal_places(n)
      Proclike.new(->(p, w) { [p.x.round(n), p.y.round(n)] })
    end
  end
end
