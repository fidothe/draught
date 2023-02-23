require 'draught/world'
require 'draught/subpath'
require 'draught/parser/svg'
require 'pathname'

module Draught::Parser
  RSpec.describe SVG do
    def fixture(name)
      (Pathname.new(__dir__)/'../../fixtures/parser/svg').join(name)
    end

    def p(x, y)
      world.point.new(x, y)
    end

    def c(p1, c1, c2, p2)
      world.curve_segment.build(start_point: p1, control_point_1: c1, control_point_2: c2, end_point: p2)
    end

    let(:world) { Draught::World.new }

    context "parsing a document containing a simple path" do
      context "an SVG containing 1 path with 3 points" do
        subject { described_class.new(world, fixture('simple-path.svg').open('r:utf-8')) }

        specify "returns a box containing a path" do
          actual = subject.parse!

          expect(actual).to be_a(Draught::Boxlike)
          expect(actual.paths.size).to eq(1)
        end

        specify "the path consists of a single path containing the correct points" do
          expected = world.path.build {
            points p(0,0), p(100,0), p(200,100)
          }
          path = subject.parse!.paths.first

          expect(path).to eq(expected)
        end
      end

      context "an SVG containing 1 path with a cubic" do
        subject { described_class.new(world, fixture('simple-cubic.svg').open('r:utf-8')) }

        specify "returns a box containing a path" do
          actual = subject.parse!

          expect(actual).to be_a(Draught::Boxlike)
          expect(actual.paths.size).to eq(1)
        end

        specify "the path consists of the correct points" do
          path = subject.parse!.paths.first

          expect(path.points).to eq(c(p(0,0), p(28,106), p(153,53), p(100,0)).points)
        end
      end
    end

    context "parsing a document containing multiple simple paths" do
      context "an SVG containing 2 paths with 3 points" do
        subject { described_class.new(world, fixture('multiple-simple-paths.svg').open('r:utf-8')) }
        let(:actual) { subject.parse! }

        specify "returns a box containing two paths" do
          expect(actual).to be_a(Draught::Boxlike)
          expect(actual.paths.size).to eq(2)
        end

        specify "paths[0] is the first path in SVG document order" do
          path = actual.paths[0]

          expect(path.points).to eq([p(0,0), p(100,0), p(200,100)])
        end

        specify "paths[1] is the second path in SVG document order" do
          path = actual.paths[1]

          expect(path.points).to eq([p(0,-100), p(-100,100), p(200,200)])
        end
      end
    end

    context "parsing a document with paths that have class atrributes" do
      context "an SVG containing 2 paths with classes" do
        subject { described_class.new(world, fixture('simple-classes.svg').open('r:utf-8')) }

        specify "returns a box containing 2 paths" do
          actual = subject.parse!

          expect(actual).to be_a(Draught::Boxlike)
          expect(actual.paths.size).to eq(2)
        end

        specify "path 1 has the correct annotation" do
          path = subject.parse!.paths.first

          expect(path.annotation).to eq(['c1'])
        end

        specify "path 2 has the correct annotation" do
          path = subject.parse!.paths.last

          expect(path.annotation).to eq(['c2'])
        end
      end
    end

    context "parsing a document with paths that have id atrributes" do
      context "an SVG containing 2 paths with classes" do
        subject { described_class.new(world, fixture('simple-ids.svg').open('r:utf-8')) }

        specify "returns a box containing 2 paths" do
          actual = subject.parse!

          expect(actual).to be_a(Draught::Boxlike)
          expect(actual.paths.size).to eq(2)
        end

        specify "path 1 has the correct name" do
          path = subject.parse!.paths.first

          expect(path.name).to eq('p1')
        end

        specify "path 2 has the correct annotation" do
          path = subject.parse!.paths.last

          expect(path.name).to eq('p2')
        end
      end
    end
  end
end
