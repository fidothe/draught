require 'draught/transformations'
require 'draught/vector'
require 'draught/point'

RSpec.shared_examples "a point-like thing" do
  it "has a numeric x value" do
    expect(subject.x).to be_a(Numeric)
  end

  it "has a numeric y value" do
    expect(subject.x).to be_a(Numeric)
  end

  it "has a point_type" do
    expect(subject).to respond_to(:point_type)
  end

  it "returns a single-item array containing itself when asked for #points" do
    expect(subject.points).to eq([subject])
  end

  describe "comparisons" do
    context "equality" do
      specify "one is equal to another if they have identical attributes" do
        duplicate = subject.translate(Draught::Vector::NULL)

        expect(subject == duplicate).to be(true)
      end

      specify "one is not equal to another if the other has been translated even a little bit" do
        duplicate = subject.translate(Draught::Vector.new(0, 0.000001))

        expect(subject == duplicate).to be(false)
      end

      specify "one is not equal to another if the other has a different point_type" do
        ringer = subject.translate(Draught::Vector::NULL)
        orig_point_type = ringer.point_type
        ringer_point_type = ->() { :"#{orig_point_type}#{orig_point_type}" }

        ringer.define_singleton_method(:point_type, &ringer_point_type)

        expect(subject == ringer).to be(false)
      end

      specify "one approximates another if their co-ordinates are within the specified delta" do
        approximated = subject.translate(Draught::Vector.new(0.000001, 0.000001))

        expect(subject.approximates?(approximated, 0.00001)).to be(true)
      end

      specify "one does not approximate another if the other has a different point_type" do
        ringer = subject.translate(Draught::Vector::NULL)
        orig_point_type = ringer.point_type
        ringer_point_type = ->() { :"#{orig_point_type}#{orig_point_type}" }

        ringer.define_singleton_method(:point_type, &ringer_point_type)

        expect(subject.approximates?(ringer, 0.1)).to be(false)
      end
    end
  end

  describe "manipulations in space" do
    specify "can be translated using a Vector to produce a new instance" do
      translation = Draught::Vector.new(1,2)

      expect(subject.translate(translation)).to be_a(described_class)
    end

    specify "can be transformed by an Affine transform" do
      expect(subject.transform(Draught::Transformations.x_axis_reflect)).to be_a(described_class)
    end

    specify "can be transformed by a lambda operating on Points" do
      transformer = ->(point) {
        Draught::Point.new(point.x + 1, point.y + 1)
      }

      expect(subject.transform(transformer)).to be_a(described_class)
    end
  end
end
