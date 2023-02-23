require 'securerandom'

RSpec.shared_examples "a segmentlike thing" do
  describe "closedness" do
    specify "a segment-like object cannot be closed" do
      expect(subject.closeable?).to be(false)
    end

    specify "is open" do
      expect(subject.open?).to be(true)
    end

    specify "is not closed" do
      expect(subject.closed?).to be(false)
    end

    specify "attempting to close it raises an error" do
      expect { subject.close }.to raise_error(TypeError)
    end
  end
end