require 'draught/point'
require 'draught/transformations/affine'

RSpec.shared_examples "a basic rectangular box-like thing" do
  context "manipulation in space" do
    context "translation" do
      let(:translation) { world.vector.new(5,5) }
      let(:translated) { subject.translate(translation) }

      specify "moves the origin of the box correctly" do
        expect(translated.lower_left).to eq(subject.lower_left.translate(translation))
      end

      specify "generates a new instance and does not change the original" do
        expect(translated).not_to be(subject)
      end

      specify "the dimensions of the translated box are unaffected" do
        expect(translated.width).to approximate(subject.width).tolerance(world.tolerance)
        expect(translated.height).to approximate(subject.height).tolerance(world.tolerance)
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
      let(:relocation_point) { subject.lower_left.translate(world.vector.new(-10, -10)) }
      let(:moved) { subject.move_to(relocation_point) }

      specify "moves the origin of the box correctly" do
        expect(moved.lower_left).to eq(relocation_point)
      end

      specify "generates a new instance and does not change the original" do
        expect(moved).not_to be(subject)
      end

      specify "the dimensions of the translated box are unaffected" do
        expect(moved.width).to approximate(subject.width).tolerance(world.tolerance)
        expect(moved.height).to approximate(subject.height).tolerance(world.tolerance)
      end

      specify "returns itself when moving the box would have no effect" do
        expect(subject.move_to(subject.lower_left)).to be(subject)
      end

      context "specifying which point on the box will be used as a reference" do
        it "allows the corners to be specified" do
          [:upper_left, :upper_right, :lower_left, :lower_right].each do |pos|
            moved = subject.move_to(relocation_point, position: pos)
            expect(moved.send(pos)).to eq(relocation_point)
          end
        end

        it "allows the centre-edge points to be specified" do
          [:upper_centre, :centre_right, :lower_centre, :centre_left].each do |pos|
            moved = subject.move_to(relocation_point, position: pos)
            expect(moved.send(pos)).to eq(relocation_point)
          end
        end

        it "allows the centre to be specified" do
          moved = subject.move_to(relocation_point, position: :centre)
          expect(moved.centre).to eq(relocation_point)
        end

        it "raises an error if an invalid position is used" do
          expect {
            subject.move_to(relocation_point, position: :blargle)
          }.to raise_error(ArgumentError)
        end
      end
    end

    context "equality" do
      it "compares equal to a (0,0) translation of itself" do
        expect(subject.translate(world.vector.new(0,0))).to eq(subject)
      end
    end
  end

  context "interface methods it's hard to test generically" do
    it "returns an iterable value for #paths without raising" do
      expect { subject.paths }.not_to raise_error
      expect(subject.paths).to respond_to(:each)
    end

    it "returns an iterable value for #containers without raising" do
      expect { subject.containers }.not_to raise_error
      expect(subject.containers).to respond_to(:each)
    end

    it "returns an array of box types for #box_type" do
      expect(subject.box_type).to be_a(Array)
    end
  end
end
