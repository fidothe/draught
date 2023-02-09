module Draught
  module Metadata
    # Provides common methods for dealing with metadata (like name) for path- and
    # box-like objects
    module Methods
      # @return [Instance] the metadata instance for the object
      def metadata
        @metadata ||= Metadata::BLANK
      end

      # @return [String] the metadata name of the object
      def name
        metadata.name
      end

      # @return [Boolean] whether the metadata has a (non-nil/non-empty) name
      def name?
        metadata.name?
      end

      # @return [Array<String>] metadata annotations of the object
      def annotation
        metadata.annotation
      end

      # @return [Boolean] whether the metadata has any annotations
      def annotation?
        metadata.annotation?
      end

      # @return [Draught::Style] the Style of the object
      def style
        metadata.style
      end

      # Duplicate the object, attaching a new metadata instance but changing nothing else
      #
      # @param metadata [Metadata::Instance] the new Metadata::Instance
      # @return [Object] a copy of the object with new metadata
      def with_metadata(metadata)
        raise NotImplementedError
      end

      # Duplicate the object, with a new metadata instance with updated name
      #
      # @param name [String] the new metadata name
      # @return [Object] a copy of the object with new metadata
      def with_name(name)
        with_metadata(metadata.with_name(name))
      end

      # Duplicate the object, with a new metadata instance with updated style
      #
      # @param name [Draught::Style] the new style
      # @return [Object] a copy of the object with new metadata
      def with_style(style)
        with_metadata(metadata.with_style(style))
      end

      # Duplicate the object, with a new metadata instance with updated annotations
      #
      # @param name [Array<String>] the new metadata annotations
      # @return [Object] a copy of the object with new metadata
      def with_annotation(annotation)
        with_metadata(metadata.with_annotation(annotation))
      end
    end
  end
end
