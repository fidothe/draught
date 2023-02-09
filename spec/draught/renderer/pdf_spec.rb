require 'draught/renderer/pdf'
require 'draught/world'
require 'draught/container'
require 'draught/sheet_builder'
require 'tmpdir'

module Draught::Renderer
  RSpec.describe PDF do
    let(:world) { Draught::World.new }
    let(:path) { world.path.build { |p| p << world.point.new(0,0); p << world.point.new(50,50) } }
    let(:container) { Draught::Container.new(world, path, min_gap: 50) }
    let(:sheet) {
      Draught::SheetBuilder.sheet(world, max_width: 150, max_height: 150, boxes: [container])
    }
    subject { described_class.new(sheet) }

    specify "Boxes in the sheet are passed to the render_container method with the render context" do
      context = subject.context
      expect(subject).to receive(:render_container).with(sheet, context)
      sheet.paths.each do |box|
        expect(subject).to receive(:render_container).with(box, context)
      end

      subject.render
    end

    specify "Paths in a container are passed to the render_path method with the render context" do
      context = subject.context
      sheet.paths.flat_map { |box| box.paths }.each  do |path|
        expect(subject).to receive(:render_path).with(path, context)
      end

      subject.render
    end

    specify "the Sheet can be rendered to a file" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'tmp.pdf')
        subject.render_to_file(path)

        expect(File.file?(path)).to be(true)
      end
    end

    it "provides a convenience class method for rendering a sheet to a file" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'tmp.pdf')
        described_class.render_to_file(path, sheet)

        expect(File.file?(path)).to be(true)
      end
    end
  end
end
