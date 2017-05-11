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
      expect(subject.translate(Draught::Vector::NULL)).to eq(subject)
    end

    it "does not compare equal to a (1,1) translation of itself" do
      expect(subject.translate(Draught::Vector.new(1,1))).not_to eq(subject)
    end

    it "compares approximately equal to a slightly nudged translation of itself" do
      approx_pathlike = subject.translate(Draught::Vector.new(0.000001, 0.000001))
      expect(subject.approximates?(approx_pathlike, 0.00001)).to be(true)
    end
  end

  describe "translation and transformation" do
    specify "translating a Path using a Point produces a new Path with appropriately translated Points" do
      translation = Draught::Vector.new(2,1)
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

  context "renderer methods" do
    it "returns an Array of itself for #paths" do
      expect(subject.paths).to eq([subject])
    end

    it "returns an empty Array for #containers" do
      expect(subject.containers).to eq([])
    end
  end
end
