require 'draught/circle_builder'
require 'draught/world'

module Draught
  RSpec.describe CircleBuilder do
    let(:world) { World.new }
    subject { CircleBuilder.new(world) }

    describe "creating a Circle" do
      let(:circle) { subject.new(radius: 100) }

      it "reports its radius" do
        expect(circle.radius).to eq(100)
      end

      context "handling Style and Annotation" do
        let(:metadata) { Metadata::Instance.new(name: 'name') }
        let(:circle) {
          subject.new(radius: 100, metadata: metadata)
        }

        specify "produces a Circle with the correct Metadata" do
          expect(circle.metadata).to be(metadata)
        end
      end
    end
  end
end
