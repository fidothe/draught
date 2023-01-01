require 'draught/world'
require 'draught/cubic_bezier'
require 'draught/bounding_box'
require 'draught/renderer/svg'
require 'stringio'
require 'nokogiri'

module Draught::Renderer
  RSpec.describe SVG do
    let(:world) { Draught::World.new }
    let(:out) { StringIO.new }
    subject { described_class.new(out) }

    def render
      yield(subject)
      out.string
    end

    def p(x,y)
      world.point.new(x,y)
    end

    def c(c1, c2, e)
      Draught::CubicBezier.new(world, control_point_1: c1, control_point_2: c2, end_point: e)
    end

    def l(width)
      world.line_segment.horizontal(width)
    end

    def box(objects = [])
      Draught::BoundingBox.new(world, objects)
    end

    describe "basic elements:" do
      describe "<path>" do
        context "from a LineSegment" do
          let(:line) { world.line_segment.horizontal(100) }
          let(:svg_path) { render { |svg| svg.path(line) } }
          let(:element) { Nokogiri::XML.fragment(svg_path).children.first }

          specify "has the right element name" do
            expect(element.name).to eq('path')
          end

          specify "has the right path definition" do
            expect(element.get_attribute('d')).to eq("M 0,0 L 100,0")
          end
        end

        context "from a CurveSegment" do
          let(:start_point) { p(0,0) }
          let(:control_point_1) { p(0,100) }
          let(:control_point_2) { p(100,100) }
          let(:end_point) { p(100,0) }
          let(:curve) {
            world.curve_segment.build({
              start_point: start_point,
              control_point_1: control_point_1,
              control_point_2: control_point_2,
              end_point: end_point
            })
          }
          let(:svg_path) { render { |svg| svg.path(curve) } }
          let(:element) { Nokogiri::XML.fragment(svg_path).children.first }

          specify "has the right element name" do
            expect(element.name).to eq('path')
          end

          specify "has the right path definition" do
            expect(element.get_attribute('d')).to eq("M 0,0 C 0,100 100,100 100,0")
          end
        end

        context "from a multi-point path" do
          let(:path) { world.path.new(points: [p(10,20), p(30,10), p(50,20)]) }
          let(:svg_path) { render { |svg| svg.path(path) } }
          let(:element) { Nokogiri::XML.fragment(svg_path).children.first }

          specify "has the right element name" do
            expect(element.name).to eq('path')
          end

          specify "has the right path definition" do
            expect(element.get_attribute('d')).to eq("M 10,20 L 30,10 50,20")
          end
        end

        context "from a multi-point path containing curves (a spline)" do
          let(:path) { world.path.new(points: [p(10,20), c(p(30,10), p(30,50), p(10,50)), c(p(30,20), p(30,60), p(10,60)), p(50,20)]) }
          let(:svg_path) { render { |svg| svg.path(path) } }
          let(:element) { Nokogiri::XML.fragment(svg_path).children.first }

          specify "has the right element name" do
            expect(element.name).to eq('path')
          end

          specify "has the right path definition" do
            expect(element.get_attribute('d')).to eq("M 10,20 C 30,10 30,50 10,50 C 30,20 30,60 10,60 L 50,20")
          end
        end

        context "with all-nil Style properties" do
          let(:path) { world.path.new(points: [p(10,20), p(30,10), p(50,20)]) }
          let(:svg_path) { render { |svg| svg.path(path) } }
          let(:element) { Nokogiri::XML.fragment(svg_path).children.first }

          specify "no style attribute is generated" do
            expect(!element.has_attribute?('style'))
          end
        end

        context "with non-nil Style properties" do
          let(:style) { Draught::Style.new(stroke_color: 'black', stroke_width: '1pt', fill: 'none') }
          let(:line) { world.line_segment.horizontal(100).with_new_style(style) }
          let(:svg_path) { render { |svg| svg.path(line) } }
          let(:element) { Nokogiri::XML.fragment(svg_path).children.first }
          let(:style_attr) { element.get_attribute('style') }

          specify "has a style attribute" do
            expect(element.has_attribute?('style'))
          end

          specify "sets stroke colour" do
            expect(style_attr).to match('stroke: black;')
          end

          specify "sets stroke width" do
            expect(style_attr).to match('stroke-width: 1pt;')
          end

          specify "sets fill" do
            expect(style_attr).to match('fill: none;')
          end
        end
      end

      describe "<g>" do
        let(:element) { Nokogiri::XML.fragment(svg_path).children.first }
        let(:path) { l(100) }

        context "an empty group" do
          let(:svg_path) { render { |svg| svg.g } }

          specify "has the right element name" do
            expect(element.name).to eq('g')
          end
        end

        context "a group containing paths" do
          let(:svg_path) { render { |svg| svg.g([path]) } }

          specify "has the right element name" do
            expect(element.name).to eq('g')
          end

          specify "contains a <path> child" do
            expect(element.children.length).to eq(1)
            expect(element.children.first.name).to eq('path')
          end
        end

        context "a group containing a group" do
          let(:svg_path) { render { |svg| svg.g([box([path])]) } }

          specify "has the right element name" do
            expect(element.name).to eq('g')
          end

          specify "contains a <g> child" do
            expect(element.children.length).to eq(1)
            expect(element.children.first.name).to eq('g')
          end
        end
      end
    end

    describe "complete documents" do
      let(:path_1) { l(100) }
      let(:path_2) { l(100).translate(world.vector.new(0,100)) }
      let(:container) { box([path_1, path_2]) }

      context "producing a complete SVG doc" do
        let(:result) { render { |svg| svg.doc(container) } }
        let(:result_doc) { Nokogiri.XML(result) }

        specify "which begins with the XML declaration" do
          expect(result).to start_with("<?xml")
        end

        describe "the svg element" do
          let(:root) { result_doc.root }

          specify "is the document element" do
            expect(root.name).to eq("svg")
          end

          specify "has the correct namespace" do
            expect(root.namespace.href).to eq("http://www.w3.org/2000/svg")
          end

          specify "takes its width from the root container" do
            expect(root.get_attribute('width')).to eq(container.width.to_s)
          end

          specify "takes its height from the root container" do
            expect(root.get_attribute('height')).to eq(container.height.to_s)
          end
        end

        context "rendered paths" do
          let(:root) { result_doc.root }

          specify "contains two" do
            expect(root.children.length).to eq(2)
          end

          context "first path" do
            let(:element) { root.children[0] }

            specify "has the right element name" do
              expect(element.name).to eq('path')
            end

            specify "has the right path definition" do
              expect(element.get_attribute('d')).to eq("M 0,0 L 100,0")
            end
          end

          context "second path" do
            let(:element) { root.children[1] }

            specify "has the right element name" do
              expect(element.name).to eq('path')
            end

            specify "has the right path definition" do
              expect(element.get_attribute('d')).to eq("M 0,100 L 100,100")
            end
          end
        end
      end
    end
  end
end
