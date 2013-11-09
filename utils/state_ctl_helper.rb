class NemipsState
  def self.defalut_value
    {alu_op: nil, wd_src: nil, regdist: nil, inst_or_data: nil,
     sram_cmd: "sram_cmd_none", pc_src: nil, alu_srcA: nil,
     alu_srcB: nil, go_src: "go_src_ok", io_read_cmd: "io_length_none",
     io_write_cmd: "io_length_none",
     inst_write: 0, pc_write: 0, mem_write: 0, ireg_write: 0,
     pc_branch: 0, a2_src_rd: 0}
  end

  def self.types
    {alu_op: "alu_op", wd_src: "wd_src", regdist: "regdist", inst_or_data: "iord",
     sram_cmd: "sram_cmd", pc_src: "pc_src", alu_srcA: "alu_srcA",
     alu_srcB: "alu_srcB", go_src: "go_src", io_read_cmd: "io_length",
     io_write_cmd: "io_length",
     inst_write: 1, pc_write: 1, mem_write: 1, ireg_write: 1,
     pc_branch: 1, a2_src_rd: 1}
  end

  def self.format(k, v)
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

  def self.typeformat(k)
    type = self.types[k]
    case type
    when String
      "#{type}_type"
    when 1
      "std_logic"
    else
      "std_logic_vector(#{type - 1} downto 0)"
    end
  end

  defalut_value.each { |k, _| define_method("#{k}") {@options[k]}}

  attr_reader :name

  def initialize(name, options = {})
    @name = name
    @options = NemipsState.defalut_value.merge Hash[options.map{|k,v| [k.to_sym, v]}]
  end

  def to_hash
    {state: @name}.merge @options.select {|_, v| !v.nil?}
  end

  def assign
    @options.map {|k, v| "#{k} => #{NemipsState.format(k, v)}" }.join(",\n")
  end
end
