require 'matrix'
module Draught
  module Transformations
    extend self

    MM_TO_PT = 2.8346456692913

    def mm_to_pt
      Matrix[
        [MM_TO_PT, 0, 0],
        [0, MM_TO_PT, 0],
        [0, 0, 1]
      ]
    end

    def x_axis_reflect
      Matrix[
        [1,0,0],
        [0,-1,0],
        [0,0,1]
      ]
    end

    def y_axis_reflect
      Matrix[
        [-1,0,0],
        [0,1,0],
        [0,0,1]
      ]
    end

    def xy_axis_reflect
      x_axis_reflect * y_axis_reflect
    end
  end
end
