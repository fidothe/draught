require 'draught/metadata/instance'

module Draught::Metadata
  RSpec.describe Instance do
    describe "blank instance" do
      specify "has no name" do
        expect(subject.name).to be_nil
      end

      specify "reports it has no name" do
        expect(subject.name?).to be(false)
      end

      specify "has a blank Style" do
        expect(subject.style).to be_a(Draught::Style)
      end

      specify "has no annotation" do
        expect(subject.annotation).to eq([])
      end

      specify "reports it has no annotation" do
        expect(subject.annotation?).to be(false)
      end
    end

    describe "initialization" do
      let(:style) { Draught::Style.new(stroke_color: 'hot pink') }
      subject { described_class.new(style: style, annotation: ['score'], name: 'name') }

      specify "returns its style" do
        expect(subject.style).to be(style)
      end

      specify "returns its name" do
        expect(subject.name).to eq('name')
      end

      specify "reports it has a name" do
        expect(subject.name?).to be(true)
      end

      specify "returns its annotation" do
        expect(subject.annotation).to eq(['score'])
      end

      specify "reports it has an annotation" do
        expect(subject.annotation?).to be(true)
      end
    end

    context "names" do
      specify "with a nil name, #name? returns false" do
        metadata = described_class.new(name: nil)

        expect(metadata.name?).to be(false)
      end

      specify "with an empty-string name, #name? returns false" do
        metadata = described_class.new(name: '')

        expect(metadata.name?).to be(false)
      end

      specify "the name is a frozen duplicate" do
        name = +'one'
        metadata = described_class.new(name: name)

        expect(metadata.name.frozen?).to be(true)
        expect(metadata.name).to_not be(name)
      end

      specify "if the name is already frozen, it's not duplicated" do
        name = -'one'
        metadata = described_class.new(name: name)

        expect(metadata.name).to be(name)
      end
    end

    context "annotations" do
      specify "the annotations array is a frozen duplicate" do
        annotation = ['one']
        metadata = described_class.new(annotation: annotation)

        expect(metadata.annotation.frozen?).to be(true)
        expect(metadata.annotation).to_not be(annotation)
      end

      specify "if the the annotations array is already frozen, it's not duplicated" do
        annotation = ['one'].freeze
        metadata = described_class.new(annotation: annotation)

        expect(metadata.annotation).to be(annotation)
      end
    end

    describe "generating new instances from an existing one" do
      specify "a copy of itself can be a returned with a simple string name set" do
        renamed = subject.with_name('name')

        expect(renamed.name).to eq('name')
      end

      it "can return a copy of itself with a new Style object attached" do
        new_style = Draught::Style.new(stroke_color: 'hot pink')
        restyled = subject.with_style(new_style)

        expect(restyled.style).to be(new_style)
      end

      specify "a copy of itself can be returned with a new Annotation object attached" do
        annotation = %w{score}
        annotated = subject.with_annotation(annotation)

        expect(annotated.annotation).to eq(annotation)
      end
    end
  end
end
