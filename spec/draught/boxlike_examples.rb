require 'draught/point'
require 'draught/transformations/affine'

RSpec.shared_examples "a basic rectangular box-like thing" do
  context "the box's dimensions" do
    context "basic information" do
      context "corners" do
        it "reports the lower-left corner as a Point" do
          expect(subject.lower_left).to be_a(Draught::Point)
        end

        it "reports the lower-right corner as a Point" do
          expect(subject.lower_right).to be_a(Draught::Point)
        end

        it "reports the upper-right corner as a Point" do
          expect(subject.upper_right).to be_a(Draught::Point)
        end

        it "reports the upper-left corner as a Point" do
          expect(subject.upper_left).to be_a(Draught::Point)
        end

        it "returns all its corners in an array, anti-clockwise starting lower-left" do
          expect(subject.corners).to eq([
            subject.lower_left, subject.lower_right,
            subject.upper_right, subject.upper_left
          ])
        end
      end

      it "reports its width correctly" do
        expect(subject.width).to eq(subject.upper_right.x - subject.lower_left.x)
      end

      it "reports its height correctly" do
        expect(subject.height).to eq(subject.upper_right.y - subject.lower_left.y)
      end
    end
  end

  context "manipulation in space" do
    context "translation" do
      let(:translation) { Draught::Vector.new(5,5) }
      let(:translated) { subject.translate(translation) }

      specify "moves the origin of the box correctly" do
        expect(translated.lower_left).to eq(subject.lower_left.translate(translation))
      end

      specify "generates a new instance and does not change the original" do
        expect(translated).not_to be(subject)
      end

      specify "the dimensions of the translated box are unaffected" do
        expect(translated.width).to eq(subject.width)
        expect(translated.height).to eq(subject.height)
      end
    end

    context "transformation" do
      let(:transformer) {
        Draught::Transformations::Affine.new(Matrix[[2,0,0],[0,2,0],[0,0,1]])
      }
      let(:transformed) { subject.transform(transformer) }

      specify "moves the origin of the box correctly" do
        expect(transformed.lower_left).to eq(subject.lower_left.transform(transformer))
      end

      specify "generates a new instance and does not change the original" do
        expect(transformed).not_to be(subject)
      end

      specify "the dimensions of the transformed box are totes affected" do
        expect(transformed.width).to eq(subject.width * 2)
        expect(transformed.height).to eq(subject.height * 2)
      end
    end

    context "relocation" do
      let(:relocation_point) { subject.lower_left.translate(Draught::Vector.new(-10, -10)) }
      let(:moved) { subject.move_to(relocation_point) }

      specify "moves the origin of the box correctly" do
        expect(moved.lower_left).to eq(relocation_point)
      end

      specify "generates a new instance and does not change the original" do
        expect(moved).not_to be(subject)
      end

      specify "the dimensions of the translated box are unaffected" do
        expect(moved.width).to eq(subject.width)
        expect(moved.height).to eq(subject.height)
      end

      specify "returns itself when moving the box would have no effect" do
        expect(subject.move_to(subject.lower_left)).to be(subject)
      end
    end

    context "equality" do
      it "compares equal to a (0,0) translation of itself" do
        expect(subject.translate(Draught::Vector.new(0,0))).to eq(subject)
      end
    end
  end

  context "interface methods it's hard to test generically" do
    context "overlaps?" do
      it { is_expected.to respond_to(:overlaps?) }

      specify "overlaps? takes one argument" do
        expect(subject.method(:overlaps?).arity).to eq(1)
      end
    end

    it "returns an iterable value for #paths without raising" do
      expect { subject.paths }.not_to raise_error
      expect(subject.paths).to respond_to(:each)
    end

    it "returns an iterable value for #containers without raising" do
      expect { subject.containers }.not_to raise_error
      expect(subject.containers).to respond_to(:each)
    end

    it "returns a numeric value for #min_gap" do
      expect { subject.min_gap }.not_to raise_error
      expect(subject.min_gap).to be_a(Integer)
    end

    it "returns an array of box types for #box_type" do
      expect(subject.box_type).to be_a(Array)
    end
  end
end
