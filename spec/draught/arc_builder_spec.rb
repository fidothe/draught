require 'draught/arc_builder'
require 'draught/world'

module Draught
  RSpec.describe ArcBuilder do
    let(:world) { World.new }
    let(:degrees) { 90 }
    let(:radians) { deg_to_rad(degrees) }
    let(:metadata) { Metadata::Instance.new(name: 'name') }
    subject { ArcBuilder.new(world) }

    describe "creating an Arc" do
      let(:arc) { subject.build(radians: radians, radius: 100) }

      it "defaults to a starting angle of 0 radians" do
        expect(arc.starting_angle).to eq(0)
      end

      it "reports its total angle in radians" do
        expect(arc.radians).to eq(radians)
      end

      it "reports its radius" do
        expect(arc.radius).to eq(100)
      end

      context "handling Metadata" do
        let(:arc) {
          subject.build(radians: radians, radius: 100, metadata: metadata)
        }

        specify "produces an Arc with the correct Metadata" do
          expect(arc.metadata).to be(metadata)
        end
      end
    end

    context "convenience creators" do
      specify "ArcBuilder.degrees() provides a simple degrees-based angle and starting_angle creator" do
        arc = subject.degrees(angle: 180, starting_angle: 90, radius: 1)
        expect(arc.radians).to eq(Math::PI)
        expect(arc.starting_angle).to eq(Math::PI/2)
        expect(arc.radius).to eq(1)
      end

      specify "ArcBuilder.radians() provides a radians-only constructor" do
        arc = subject.radians(angle: Math::PI, starting_angle: Math::PI/2, radius: 1)
        expect(arc.radians).to eq(Math::PI)
        expect(arc.starting_angle).to eq(Math::PI/2)
        expect(arc.radius).to eq(1)
      end

      context "handling Metadata" do
        [:radians, :degrees].each do |meth|
          context "##{meth}" do
            let(:arc) {
              subject.send(meth, angle: 2, radius: 1, metadata: metadata)
            }

            specify "produces an Arc with the correct Metadata" do
              expect(arc.metadata).to be(metadata)
            end
          end
        end
      end
    end
  end
end
