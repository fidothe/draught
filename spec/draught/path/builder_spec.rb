require 'draught/world'
require 'draught/point'
require 'draught/style'
require 'draught/path/builder'

module Draught
  RSpec.describe Path::Builder do
    let(:world) { World.new }
    let(:p1) { world.point(1,1) }
    let(:p2) { world.point(2,2) }
    let(:metadata) { Metadata::Instance.new(name: 'name') }
    subject { described_class.new(world) }

    describe "creating a new Path" do
      specify "which is empty" do
        path = subject.new
        expect(path.points).to eq([])
        expect(path.world).to be(world)
      end

      specify "from an array of Points" do
        path = subject.new(points: [p1, p2])
        expect(path.points).to eq([p1, p2])
        expect(path.world).to be(world)
      end

      specify "including Metadata" do
        path = subject.new(points: [p1, p2], metadata: metadata)
        expect(path.metadata).to be(metadata)
      end
    end

    describe "creating a simple path" do
      specify "only requires passing points" do
        path = subject.simple(p1, p2)

        expect(path.points).to eq([p1, p2])
        expect(path.world).to be(world)
      end

      specify "metadata is correctly passed" do
        path = subject.simple(p1, p2, metadata: metadata)
        expect(path.metadata).to be(metadata)
      end

      specify "can create a closed path" do
        path = subject.simple(p1, p2, closed: true)

        expect(path.closed?).to be(true)
      end
    end

    describe "building a path via a DSL" do
      context "a simple path" do
        let(:expected_path) {
          subject.new(points: [p1, p2])
        }

        it "executes a DSL block and returns a Path" do
          p1a, p2a = p1, p2 # scoping for #build
          path = subject.build {
            points p1a, p2a
          }

          expect(path).to eq(expected_path)
        end

        it "#points DSL method can be called multiple times, appending to the path" do
          p1a, p2a = p1, p2 # scoping for #build
          path = subject.build {
            points p1a
            points p2a
          }

          expect(path).to eq(expected_path)
        end

        context "appending a Pathlike as if it were a Point" do
          specify "appends the points from the Path" do
            p1a, p2a = p1, p2 # scoping for #build
            compatible_path = subject.build {
              points p1a, p2a
            }

            path = subject.build {
              points compatible_path
            }

            expect(path).to eq(compatible_path)
          end
        end

        specify "can create a closed path" do
          path = subject.build {
            points p(1,1), p(2,2)
            closed
          }

          expect(path.closed?).to be(true)
        end

        specify "provides a way to access the current last Point in the path" do
          collector = []
          path = subject.build {
            points p(1,1), p(2,2)
            collector << last_point
          }

          expect(collector).to eq([p2])
        end
      end

      specify "provides a new point shorthand method" do
        expected_path = subject.new(points: [p1, p2])

        path = subject.build {
          points p(1,1), p(2,2)
        }

        expect(path).to eq(expected_path)
      end

      specify "provides a degrees-to-radians converter method" do
        collector = []

        path = subject.build {
          collector << deg_to_rad(90)
          points p(1,1), p(2,2)
        }

        expect(collector).to eq([deg_to_rad(90)]) # using spec helper converter method here
      end

      specify "the World is accessible" do
        collector = []
        subject.build {
          collector << self.world
        }

        expect(collector).to eq([subject.world])
      end

      context "handling Metadata" do
        let(:style_attrs) { {fill: 'hot pink'} }
        let(:style_obj) {
          Draught::Style.new(**style_attrs)
        }
        let(:metadata_attrs) { {style: style_obj, name: 'name', annotation: %w{score}} }
        let(:metadata_obj) { Metadata::Instance.new(**metadata_attrs) }

        context "the complete Metadata object can be set" do
          specify "by passing a Metadata::Instance" do
            metadata_obj_a = metadata_obj # scoping
            path = subject.build {
              metadata metadata_obj_a
            }
            expect(path.metadata).to be(metadata_obj)
          end

          specify "by passing kwargs" do
            metadata_attrs_a = metadata_attrs # scoping
            path = subject.build {
              metadata **metadata_attrs_a
            }
            expect(path.metadata).to eq(metadata_obj)
          end

          specify "kwargs for style can be passed as a hash in the kwargs" do
            style_attrs_a = style_attrs # scoping
            path = subject.build {
              metadata style: style_attrs_a, name: 'name', annotation: %w{score}
            }
            expect(path.metadata).to eq(metadata_obj)
          end
        end

        context "setting Style" do
          specify "with a Draught::Style" do
            style_obj_a = style_obj # scoping
            path = subject.build {
              style style_obj_a
            }
            expect(path.style).to be(style_obj)
          end

          specify "with kwargs" do
            style_attrs_a = style_attrs # scoping
            path = subject.build {
              style **style_attrs_a
            }
            expect(path.style).to eq(style_obj)
          end
        end

        context "setting annotations" do
          specify "as a sequence of args" do
            path = subject.build {
              annotation 'score', 'layer-1'
            }
            expect(path.annotation).to eq(['score', 'layer-1'])
          end

          specify "as an Enumerable" do
            path = subject.build {
              annotation ['score', 'layer-1']
            }
            expect(path.annotation).to eq(['score', 'layer-1'])
          end

          specify "as an annoying mix of args and enumerables" do
            path = subject.build {
              annotation 'score', ['layer-1']
            }
            expect(path.annotation).to eq(['score', 'layer-1'])
          end
        end

        specify "name can be set" do
          path = subject.build {
            name 'name'
          }
          expect(path.name).to eq('name')
        end

        specify "last one set wins" do
          metadata_obj_a = metadata_obj # scoping
          path = subject.build {
            metadata metadata_obj_a
            name 'other'
          }

          expect(path.metadata).to_not eq(metadata_obj)
          expect(path.name).to eq('other')
        end

        specify "setting the complete object last wipes existing style/name/annotation" do
          metadata_obj_a = metadata_obj # scoping
          path = subject.build {
            style fill: 'fuschia'
            annotation 'cut'
            name 'other'
            metadata metadata_obj_a
          }

          expect(path.metadata).to be(metadata_obj)
          expect(path.name).to_not eq('other')
        end
      end
    end

    describe "connecting several paths together" do
      let(:horizontal) { subject.build { points p(0,0), p(1,0) } }
      let(:diagonal) { subject.build { points p(0,0), p(1,1) } }
      let(:spaced_horizontal) { subject.build {
        points p(2,0), p(3,0)
      } }

      it "connects by translating the first point of the next path onto the last point of the previous and eliminating duplicates" do
        expected = subject.build { points p(0,0), p(1,0), p(2,1), p(3,1) }

        path = subject.connect(horizontal, diagonal, spaced_horizontal)

        expect(path).to eq(expected)
      end

      it "copes if one or more of the paths to connect are empty" do
        expected = subject.build { points p(0,0), p(1,0), p(2,1), p(3,1) }

        path = subject.connect(Path.new(world), horizontal, diagonal, Path.new(world), spaced_horizontal, Path.new(world))

        expect(path).to eq(expected)
      end

      specify "allows marking the resulting path closed" do
        path = subject.connect(horizontal, diagonal, closed: true)

        expect(path.closed?).to be(true)
      end

      context "handling Metadata" do
        let(:styled_horizontal) { horizontal.with_metadata(metadata) }

        context "when a path being connected has metadata, but there's no explicit metadata supplied" do
          let(:connected) { subject.connect(styled_horizontal, diagonal, spaced_horizontal) }

          specify "the resulting path has null metadata" do
            expect(connected.metadata).to_not be(metadata)
          end
        end

        context "when the builder specifies Metadata" do
          let(:joined) { subject.connect(horizontal, diagonal, spaced_horizontal, metadata: metadata) }

          specify "the resulting path has the correct Metadata" do
            expect(joined.metadata).to be(metadata)
          end
        end
      end
    end
  end
end
