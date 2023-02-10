require_relative '../style'

module Draught
  module Metadata
    class Instance
      attr_reader :style, :name, :annotation

      # @!attribute [r] name
      #   @return [String] the metadata name of the object
      # @!attribute [r] style
      #   @return [Draught::Style] the Style for the object
      # @!attribute [r] annotation
      #   @return [Array<String>] annotation strings for the object

      # @param style [Draught::Style] the Style for the object
      # @param annotation [Array<String>] ([]) annotations for the object
      # @param name [String] (nil) a name for the object
      def initialize(style: Style.new, annotation: [], name: nil)
        @style = style
        @annotation = annotation.frozen? ? annotation : annotation.dup.freeze
        @name = name.nil? ? name : -name
      end

      # @return [Boolean] whether this instance has a non-nil/non-empty name set
      def name?
        !(@name.nil? || @name == '')
      end

      # @return [Boolean] whether this instance has any annotations
      def annotation?
        !(@annotation.empty?)
      end

      # return a copy of this object with a Style attached, replacing any existing Style
      #
      # @param style [Style] the Style to use
      # @return [Metadata::Instance] the copy of this Metadata::Instance with new annotation
      def with_style(style)
        self.class.new(style: style, annotation: annotation, name: name)
      end

      # return a copy of this object with an Annotation attached, replacing any existing Annotation
      #
      # @param annotation [Array<String>] the Annotation to use
      # @return [Metadata::Instance] the copy of this Metadata::Instance with new annotation
      def with_annotation(annotation)
        self.class.new(style: style, annotation: annotation, name: name)
      end

      # return a copy of this object with a name, replacing any existing name
      #
      # @param name [String] the name to use
      # @return [Metadata::Instance] the copy of this Metadata::Instance with new name
      def with_name(name)
        self.class.new(style: style, annotation: annotation, name: name)
      end
    end

    BLANK = Instance.new
  end
end
