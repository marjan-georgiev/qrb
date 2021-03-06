module Qrb
  module CollectionType

    def initialize(elm_type, name = nil)
      unless elm_type.is_a?(Type)
        raise ArgumentError, "Qrb::Type expected, got `#{elm_type}`"
      end

      super(name)
      @elm_type = elm_type
    end
    attr_reader :elm_type

    def ==(other)
      return false unless other.is_a?(self.class)
      elm_type == other.elm_type
    end
    alias :eql? :==

    def hash
      self.class.hash ^ self.elm_type.hash
    end

  end # module CollectionType
end # module Qrb
