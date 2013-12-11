class NemipsState
  class << self
    attr_reader :default_value, :types, :state_prefix
    def load_definetions(hash)
      @default_value = Hash[hash["default"].map {|k, v| [k.to_sym, v]}]
      @types = Hash[hash["types"].map {|k, v| [k.to_sym, v]}]
      @state_prefix = hash["settings"]["state_name"]
    end

    def format(k, v)
      type = self.types[k]
      case type
      when String, Symbol
        v.to_s
      when Integer
        if type == 1
          v && (v != 0) ? "'1'" : "'0'"
        else
          "\"#{2 ** type + v}\""
        end
      end
    end

    def typeformat(k)
      type = self.types[k]
      case type
      when String
        "#{type}_type"
      when 1
        "std_logic"
      when Fixnum
        "std_logic_vector(#{type - 1} downto 0)"
      else
        STDERR.puts k, type
        raise
      end
    end
  end

  #defalut_value.each { |k, _| define_method("#{k}") {@options[k]}}

  def initialize(name, options = {})
    @name = name
    @options = NemipsState.default_value.merge(
      Hash[(options || {}).map{|k,v| [k.to_sym, v]}])
  end

  def to_hash
    {state: @name}.merge @options.select {|_, v| !v.nil?}
  end

  def assign
    @options.map {|k, v| "#{k} => #{NemipsState.format(k, v)}" }.join(",\n")
  end

  def original_name
    @name
  end

  def name
    "#{NemipsState.state_prefix}_#{@name}"
  end

  def ctl_name
    "#{NemipsState.state_prefix}_#{@name}_ctl"
  end
end
