require 'hocon'

class Hocon::ConfigError < StandardError
  def initialize(origin, message, cause)
    super(message)
    @origin = origin
    @cause = cause
  end

  class ConfigMissingError < Hocon::ConfigError
  end

  class ConfigNullError < Hocon::ConfigError::ConfigMissingError
    def self.make_message(path, expected)
      if not expected.nil?
        "Configuration key '#{path}' is set to nul but expected #{expected}"
      else
        "Configuration key '#{path}' is null"
      end
    end
  end

  class ConfigParseError < Hocon::ConfigError
  end

  class ConfigWrongTypeError < Hocon::ConfigError
  end
end
