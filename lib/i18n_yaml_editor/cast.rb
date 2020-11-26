# frozen_string_literal: true

module I18nYamlEditor
  # Transformation provides
  module Cast
    # Lists all supported types of conversions
    TYPES = %i[numeric boolean array].freeze

    # Contains a check method for each supported type
    CHECK = {
      numeric: ->(klass) { klass < Numeric },
      boolean: ->(klass) { [TrueClass, FalseClass].include?(klass) },
      array: ->(klass) { klass == Array }
    }.freeze

    # Contains a conversion method for each supported type
    CONVERT = {
      numeric: lambda do |value|
                 num = BigDecimal(value)
                 num.frac.zero? ? num.to_i : num.to_f
               end,
      boolean: ->(value) { value.casecmp('true').zero? },
      array: ->(value) { value.split("\r\n") }
    }.freeze

    # Converts a given value to a specific data type
    def cast(klass, value)
      TYPES.each do |type|
        return CONVERT[type].call(value) if CHECK[type].call(klass)
      end
      # String, blank
      # remove carriage returns injected by textarea fields
      value.to_s.tr("\r", '')
    end
  end
end
