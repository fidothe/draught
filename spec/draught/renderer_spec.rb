require 'draught/renderer'
require 'draught/point'
require 'draught/path_builder'
require 'draught/container'
require 'draught/sheet_builder'
require 'tmpdir'

module Draught
  RSpec.describe Renderer do
    let(:path) { PathBuilder.build { |p| p << Point.new(0,0); p << Point.new(50,50) } }
    let(:container) { Container.new(path, min_gap: 50) }
    let(:sheet) {
      box = container
      SheetBuilder.build(max_width: 150, max_height: 150) { add box }
    }
    subject { Renderer.new(sheet) }

    specify "Boxes in the sheet are passed to the render_container method with the render context" do
      context = subject.context
      sheet.containers.each do |box|
        expect(subject).to receive(:render_container).with(box, context)
      end

      subject.render
    end

    specify "Paths in a container are passed to the render_path method with the render context" do
      context = subject.context
      sheet.containers.flat_map { |box| box.paths }.each  do |path|
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
        Renderer.render_to_file(sheet, path)

        expect(File.file?(path)).to be(true)
      end
    end
  end
end
