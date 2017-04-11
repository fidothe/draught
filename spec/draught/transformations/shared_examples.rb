require 'draught/transformations/composer'

RSpec.shared_examples "transformation object fundamentals" do
  it "responds to #call(), taking a single Point argument and returning the Point result of applying the transform" do
    expect(subject.call(input_point)).
      to eq(expected_point)
  end

  it "compares equal to a dup of itself" do
    expect(subject.dup).to eq(subject)
  end

  context "being aware of affine-ness" do
    it "responds to #affine?" do
      expect(subject).to respond_to(:affine?)
    end
  end

  context "transform-ness" do
    it "returns itself in response to #to_transform" do
      expect(subject.to_transform).to be(subject)
    end
  end
end

RSpec.shared_examples "composable with another transform" do
  it "produces the transformation result when composed with another transform" do
    composed = subject.compose(other_transform)
    expect(composed.call(input_point)).to eq(expected_point)
  end
end

RSpec.shared_examples "producing a transform-compatible verison of itself" do
  it "produces a correctly functioning transform in response to #to_transform" do
    expect(subject.to_transform.call(input_point)).to eq(expected_point)
  end
end
