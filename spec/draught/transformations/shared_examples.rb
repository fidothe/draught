require 'draught/transformations/composer'

RSpec.shared_examples "a well-behaved transformation class" do
  it "responds to #call(), taking a single Point argument and returning the Point result of applying the transform" do
    expect(subject.call(input_point)).
      to eq(result_point)
  end

  it "compares equal to a dup of itself" do
    expect(subject.dup).to eq(subject)
  end

  context "being aware of affine-ness" do
    it "responds to #affine?" do
      expect(subject).to respond_to(:affine?)
    end
  end

  context "composition" do
    it "returns a correctly instantiated composed transform in response to #compose" do
      expect(subject.compose(subject)).to eq(Draught::Transformations::Composer.coalesced(subject, subject))
    end

    it "returns an array consisting of itself in response to #flattened_transforms" do
      expect(subject.flattened_transforms).to eq([subject])
    end
  end
end
