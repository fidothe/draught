RSpec.shared_examples "a pathlike thing" do
  it "can return an array of its points" do
    expect(subject.points).to eq(points)
  end

  it "reports how many points it has" do
    expect(subject.number_of_points).to eq(points.length)
  end

  describe "being enumerable enough" do
    it "provides []-index access to its points" do
      expect(subject[0]).to eq(subject.points.first)
    end

    it "provides meaningful [Range] access" do
      expect {
        subject[0..1]
      }.not_to raise_error
    end

    it "provides meaningful [start, length] access" do
      expect {
        subject[0, 1]
      }.not_to raise_error
    end

    context "provides first and last readers" do
      specify { expect(subject.first).to eq(points.first) }

      specify { expect(subject.last).to eq(points.last) }
    end
  end

  describe "comparison" do
    it "compares equal to a (0,0) translation of itself" do
      expect(subject.translate(world.vector.null)).to eq(subject)
    end

    it "does not compare equal to a (1,1) translation of itself" do
      expect(subject.translate(world.vector.new(1,1))).not_to eq(subject)
    end

    it "compares approximately equal to a slightly nudged translation of itself" do
      approx_pathlike = subject.translate(world.vector.new(0.000001, 0.000001))
      expect(subject.approximates?(approx_pathlike, 0.00001)).to be(true)
    end
  end

  describe "translation and transformation" do
    specify "translating a Path using a Point produces a new Path with appropriately translated Points" do
      translation = world.vector.new(2,1)
      expected = points.map { |p| p.translate(translation) }

      expect(subject.translate(translation).points).to eq(expected)
    end

    specify "transforming a Path generates a new Path by applying the transformation to every Point in the Path" do
      transformation = Draught::Transformations::Affine.new(
        Matrix[[2,0,0],[0,2,0],[0,0,1]]
      )
      expected = points.map { |p| p.transform(transformation) }

      expect(subject.transform(transformation).points).to eq(expected)
    end
  end

  describe "style properties" do
    it "can return a Style object" do
      expect(subject.style).to be_a(Draught::Style)
    end

    it "can return a copy of itself with a new Style object attached" do
      new_style = Draught::Style.new(stroke_color: 'hot pink')
      restyled = subject.with_new_style(new_style)

      expect(restyled.style).to be(new_style)
      expect(restyled).to eq(subject)
    end

    context "transformation and translation" do
      let(:style) { Draught::Style.new(stroke_color: 'hot pink') }
      let(:restyled) { subject.with_new_style(style) }

      specify "translating a Pathlike maintains Style" do
        translation = world.vector.new(2,1)

        expect(restyled.translate(translation).style).to be(style)
      end

      specify "transforming a Pathlike maintains Style" do
        transformation = Draught::Transformations::Affine.new(
          Matrix[[2,0,0],[0,2,0],[0,0,1]]
        )

        expect(restyled.transform(transformation).style).to be(style)
      end
    end

    context "[] access" do
      let(:style) { Draught::Style.new(stroke_color: 'hot pink') }
      let(:restyled) { subject.with_new_style(style) }

      specify "preserves Style in the returned Pathlike" do
        expect(restyled[0..1].style).to be(style)
      end
    end
  end

  context "renderer methods" do
    it "returns an array including :path for #box_type" do
      expect(subject.box_type).to include(:path)
    end

    it "returns an empty Array #paths" do
      expect(subject.paths).to eq([])
    end

    it "returns an empty Array for #containers" do
      expect(subject.containers).to eq([])
    end
  end
end
