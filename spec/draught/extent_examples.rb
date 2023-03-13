require 'draught/extent'

RSpec.shared_examples "it has an extent" do
  specify "returns an extent" do
    expect(subject.extent).to be_a(Draught::Extent::Instance)
  end

  specify "should have the correct lower-left point" do
    expect(subject.lower_left).to eq(lower_left)
  end

  specify "should have the correct upper-right point" do
    expect(subject.upper_right).to eq(upper_right)
  end

  context "delegation" do
    context "0-arity methods" do
      [
        :width, :height, :x_max, :y_max, :x_min, :y_min,
        :lower_right, :upper_left, :lower_left, :upper_right,
        :lower_centre, :upper_centre, :centre_left, :centre_right,
        :centre, :corners
      ].each do |delegate|
        specify "#{delegate} is delegated correctly" do
          expect(subject).to respond_to(delegate)
          # expect(subject.method(delegate).owner).to be(subject.extent)
          expect(subject.public_send(delegate)).to eq(subject.extent.public_send(delegate))
        end
      end
    end

    context "arity-1 methods" do
      [:overlaps?, :disjoint?, :includes_point?].each do |delegate|
        specify "#{delegate} is delegated correctly" do
          expect(subject).to respond_to(delegate)
        end
      end
    end
  end
end
