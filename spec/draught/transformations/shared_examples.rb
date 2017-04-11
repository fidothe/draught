require 'draught/transformations/composer'

RSpec.shared_examples "transformation object fundamentals" do
  context "transformation object fundamentals" do
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

    context "composability" do
      it "returns an iterable object in response to #transforms" do
        expect(subject.transforms).to respond_to(:each)
      end
    end
  end
end

RSpec.shared_examples "single-transform transformation object" do
  it "returns an array of itself in response to #transforms" do
    expect(subject.transforms).to eq([subject])
  end
end

RSpec.shared_examples "producing a transform-compatible version of itself" do
  it "produces a correctly functioning transform in response to #to_transform" do
    expect(subject.to_transform.call(input_point)).to eq(expected_point)
  end
end
