require 'hocon/impl'

class Hocon::Impl::SimpleConfig

  ConfigMissingError = Hocon::ConfigError::ConfigMissingError
  ConfigNullError = Hocon::ConfigError::ConfigNullError
  ConfigWrongTypeError = Hocon::ConfigError::ConfigWrongTypeError

  def initialize(object)
    @object = object
  end

  def root
    @object
  end

  def find_key(me, key, expected, original_path)
    v = me.peek_assuming_resolved(key, original_path)
    if v.nil?
      raise ConfigMissingError.new(nil, "No configuration setting found for key '#{original_path.render}'", nil)
    end

    if not expected.nil?
      v = DefaultTransformer.transform(v, expected)
    end

    if v.value_type == ConfigValueType.NULL
      raise ConfigNullError.new(v.origin,
                                (ConfigNullError.make_message(original_path.render,
                                                              not expected.nil? ? expected.name : nil)),
                                nil)
    elsif (not expected.nil?) && v.value_type != expected
      raise ConfigWrongTypeError.new(v.origin,
                                     "#{original_path.render} has type #{v.value_type.name} " +
                                         "rather than #{expected.name}",
                                     nil)
    else
      return v
    end
  end

  def find(me, path, expected, original_path)
    key = path.first
    rest = path.remainder
    if rest.nil?
      find_key(me, key, expected, original_path)
    else
      o = find_key(me, key, Hocon::ConfigValueType.OBJECT,
                  original_path.sub-path(0, original_path.length - rest.length))
      raise "Error: object o is nil" unless not o.nil?
      find(o, rest, expected, original_path)
    end
  end

  def get_value(path)
    parsed_path = Path.new_path(path)
    find(object, parsed_path, nil, parsed_path)
  end
end