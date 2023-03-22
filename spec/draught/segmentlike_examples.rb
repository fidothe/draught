require 'securerandom'

RSpec.shared_examples "a segmentlike thing" do
  specify "have a segment_type" do
    expect(subject.segment_type).to be_a(Symbol)
  end

  describe "closedness" do
    specify "a segment-like classes cannot be closed" do
      expect(subject.class.closeable?).to be(false)
    end

    specify "a segment-like classes can be opened" do
      expect(subject.class.openable?).to be(true)
    end

    specify "a segment-like object cannot be closed" do
      expect(subject.closeable?).to be(false)
    end

    specify "a segment-like object can be opened" do
      expect(subject.openable?).to be(true)
    end

    specify "is open" do
      expect(subject.open?).to be(true)
    end

    specify "is not closed" do
      expect(subject.closed?).to be(false)
    end

    specify "attempting to close it raises an error" do
      expect { subject.closed }.to raise_error(TypeError)
    end
  end

  describe "comparison" do
    let(:random_segment_type) { SecureRandom.hex(10).to_sym }

    specify "compares equal to itself" do
      is_expected.to eq(subject)
    end

    specify "does not compare equal to a segment with different segment_type" do
      copy = subject.dup

      new_segment_type = random_segment_type
      copy.singleton_class.define_method(:segment_type) { new_segment_type }

      expect(copy).not_to eq(subject)
    end
  end
end
