module Draught
  module Transformations
    extend self

    MM_TO_PT = 2.8346456692913

    def mm_to_pt
      ->(x, y) {
        [x * MM_TO_PT, y * MM_TO_PT]
      }
    end
  end
end
