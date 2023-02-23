require 'securerandom'
require 'draught/segmentlike'

RSpec.shared_examples "a pathlike thing" do
  specify "can return an enumerable of its points" do
    expect(subject.points).to respond_to(:each)
  end

  specify "reports how many points it has" do
    expect(subject.number_of_points).to eq(subject.points.length)
  end

  describe "being enumerable enough" do
    context "[] access" do
      it "provides []-index access to its points" do
        expect(subject[0]).to eq(points.first)
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

  describe "metadata" do
    let(:name) { SecureRandom.hex(10) }
    let(:style) { Draught::Style.new(stroke_color: 'hot pink') }
    let(:annotation) { ['score'] }
    let(:metadata) {
      Draught::Metadata::Instance.new(name: name, style: style, annotation: annotation)
    }

    context "metadata-only changes" do
      specify "a copy of the object using a new metadata instance can be made" do
        metadata_updated = subject.with_metadata(metadata)

        expect(metadata_updated.metadata).to be(metadata)
        expect(metadata_updated).to eq(subject)
      end

      context "creating a copy with only a partial metadata update" do
        specify "allows a name-only update" do
          renamed = subject.with_name(name)

          expect(renamed.name).to eq(name)
          expect(renamed).to eq(subject)
        end

        specify "allows a style-only update" do
          restyled = subject.with_style(style)

          expect(restyled.style).to be(style)
          expect(restyled).to eq(subject)
        end

        specify "allows an annotation-only update" do
          annotated = subject.with_annotation(annotation)

          expect(annotated.annotation).to eq(annotation)
          expect(annotated).to eq(subject)
        end
      end

      describe "preserving metadata through transform, translate, and slice access" do
        let(:updated) { subject.with_metadata(metadata) }

        specify "translating a Pathlike preserves its metadata" do
          translation = world.vector.new(2,1)

          expect(updated.translate(translation).metadata).to be(metadata)
        end

        specify "transforming a Pathlike preserves its metadata" do
          transformation = Draught::Transformations::Affine.new(
            Matrix[[2,0,0],[0,2,0],[0,0,1]]
          )

          expect(updated.transform(transformation).metadata).to be(metadata)
        end

        specify "slice access of a Pathlike preserves metadata in the resulting Path" do
          expect(updated[0..1].metadata).to be(metadata)
        end
      end
    end
  end

  context "renderer methods" do
    specify "can return an enumerable of its subpaths" do
      expect(subject.subpaths).to respond_to(:each)
    end

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
