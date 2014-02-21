require 'set'
module Qrb
  #
  # The Abtract/Algebraic Data Type is a generator to build user-defined
  # information types in a more abstract way than using sub types. For
  # instance, a Color could be defined as follows:
  #
  #     Color := <Rgb> {r: Byte, g: Byte, b: Byte},
  #              <Hex> String( s | s =~ /^#[0-9a-f]{6}$/i )
  #
  # Such a declaration does not define a new type by *subtyping* but instead
  # declares so-called possible representations for the color. Here, two
  # possible representations are defined: one is a rgb triple through a Tuple
  # type, the other is an hexadecimal notation through a subset of String.
  #
  # Given an AdType, Q requires special dress/undress function pairs to
  # encode/decode from the type to the concrete representations and vice versa.
  # This pair of functions is called the "information contract".
  #
  # This class allows capturing such information types. For instance,
  #
  #     # This is the concrete representation of Q's Color, through a usual
  #     # Ruby ADT (we call it ColorImpl here to avoid confusion, but in
  #     # practice one would simply call it Color).
  #     class ColorImpl
  #       # ... your usual color implementation
  #     end
  #
  #     # The RGB info type: {r: Byte, g: Byte, b: Byte}
  #     rgb_infotype  = TupleType.new(...)
  #
  #     # The RGB contract, an object that responds to `rgb` to convert from
  #     # a valid Hash[r: Fixnum, ...] to a ColorImpl instance. The latter is
  #     # is expected to respond to :to_rgb
  #     rgb_contract = ...
  #
  #     AdType.new(ColorImpl, rgb: [rgb_infotype, rgb_contract], hex: ...)
  #
  # The ruby ADT class is of course used as concrete representation of the
  # AdType, that is,
  #
  #     R(Color) = ColorImpl
  #
  # Accordingly, the `up` transformation function has the following signature:
  #
  #     up :: Alpha  -> Color     throws TypeError
  #     up :: Object -> ColorImpl throws UpError
  #
  class AdType < Type

    def initialize(ruby_type, contracts, name = nil)
      unless ruby_type.is_a?(Module)
        raise ArgumentError, "Module expected, got `#{ruby_type}`"
      end
      unless contracts.is_a?(Hash)
        raise ArgumentError, "Hash expected, got `#{contracts}`"
      end

      super(name)
      @ruby_type = ruby_type
      @contracts = contracts.freeze
    end
    attr_reader :ruby_type, :contracts

    def default_name
      ruby_type.name.to_s
    end

    def up(value, handler = UpHandler.new)
      # Try each contract in turn. Do nothing on UpError as
      # the next candidate could be the good one! Return the
      # first successfully uped.
      contracts.each_pair do |name, (infotype,upper)|

        # First make the up on the information type
        success, uped = handler.just_try do
          infotype.up(value, handler)
        end
        next unless success

        # Seems nice, just try to get one stage higher now
        success, uped = handler.just_try do
          upper.send(name, uped)
        end
        return uped if success

      end

      # No one succeededr, just fail
      handler.failed!(self, value)
    end

  end # class AdType
end # module Qrb
