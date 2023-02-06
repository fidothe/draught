require 'draught/metadata/methods'
require 'draught/metadata/instance'

module Draught::Metadata
  RSpec.describe Methods do
    let(:klass) {
      Class.new {
        include Methods

        attr_reader :metadata

        def initialize(metadata = nil)
          @metadata = metadata
        end

        def with_metadata(metadata)
          self.class.new(metadata)
        end
      }
    }

    describe "accessing a metadata instance from an instance of the including class" do
      let(:name) { 'name' }
      let(:annotation) { ['score'] }
      let(:style) { Draught::Style.new(stroke_color: 'hot pink') }
      let(:metadata) { Instance.new(name: name, annotation: annotation, style: style) }

      subject { klass.new(metadata) }

      specify { expect(subject.name).to eq('name') }
      specify { expect(subject.name?).to be(true) }
      specify { expect(subject.annotation).to eq(['score']) }
      specify { expect(subject.annotation?).to be(true) }
      specify { expect(subject.style).to be(style) }
    end

    describe "creating a new instance of the including class with new metadata" do
      let(:name) { 'name' }
      let(:annotation) { ['score'] }
      let(:style) { Draught::Style.new(stroke_color: 'hot pink') }
      let(:metadata) { Instance.new(name: name, annotation: annotation, style: style) }

      subject { klass.new(metadata) }

      context "the whole metadata object" do
        let(:new_metadata) { Instance.new(name: 'new') }

        specify "a with_metadata method is expected" do
          new_instance = subject.with_metadata(new_metadata)

          expect(new_instance.metadata).to be(new_metadata)
        end
      end

      context "one part of the metadata object" do
        context "name" do
          let(:new_instance) { subject.with_name('new-name') }
          let(:new_metadata) { new_instance.metadata }

          specify "can generate a new instance with new metadata object" do
            expect(new_metadata).to_not be(metadata)
            expect(new_metadata.name).to eq('new-name')
          end

          specify "other metadata attrs are carried over" do
            expect(new_metadata.style).to be(style)
          end
        end

        context "style" do
          let(:new_style) { Draught::Style.new(stroke_color: 'cold pink') }
          let(:new_instance) { subject.with_style(new_style) }
          let(:new_metadata) { new_instance.metadata }

          specify "can generate a new instance with new metadata object" do
            expect(new_metadata).to_not be(metadata)
            expect(new_metadata.style).to be(new_style)
          end

          specify "other metadata attrs are carried over" do
            expect(new_metadata.annotation).to eq(annotation)
          end
        end

        context "annotation" do
          let(:new_instance) { subject.with_annotation(['cut']) }
          let(:new_metadata) { new_instance.metadata }

          specify "can generate a new instance with new metadata object" do
            expect(new_metadata).to_not be(metadata)
            expect(new_metadata.annotation).to eq(['cut'])
          end

          specify "other metadata attrs are carried over" do
            expect(new_metadata.name).to eq('name')
          end
        end
      end
    end
  end
end
