require 'draught/extent'

RSpec.shared_examples "it has an extent" do
  specify "returns an extent" do
    expect(subject.extent).to be_a(Draught::Extent)
  end

  specify "should have the correct lower-left point" do
    expect(subject.lower_left).to eq(lower_left)
  end

  specify "should have the correct upper-right point" do
    expect(subject.upper_right).to eq(upper_right)
  end

  context "delegation" do
    [:width, :height, :x_max, :y_max, :x_min, :y_min, :lower_right, :upper_left].each do |delegate|
      specify "#{delegate} is delegated correctly" do
        expect(subject.public_send(delegate)).to eq(subject.extent.public_send(delegate))
      end
    end
  end
end
