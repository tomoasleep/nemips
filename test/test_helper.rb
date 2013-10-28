def exclude_filename_match(path, *exclude_regexps)
  res = Dir[File.expand_path(path, File.dirname(__FILE__))].select { |f| !exclude_regexps.one? { |e| f.match(e) } }
end

class Integer
  def to_binary(length=2)
    "\"#{(2**length + self).to_s(2)[-length..-1]}\""
  end

  def to_logic_vector(length)
    self.to_s(2).rjust(length, '0').unpack("C*").map{|i| i - 48}.reverse
  end

  def bit_range(max, min)
    (self >> min) & (2 ** (max - min + 1) - 1)
  end

  def split_byte
    [bit_range(7, 0), bit_range(15, 8), bit_range(23, 16), bit_range(31, 24)]
  end
end

def instruction_r(op, rs, rt, rd, shamt, funct)
  "#{op} & #{rs.to_binary(5)} & #{rt.to_binary(5)} & #{rd.to_binary(5)} & #{shamt.to_binary(5)} & #{funct}"
end

def instruction_i(op, rs, rt, imm)
  "#{op} & #{rs.to_binary(5)} & #{rt.to_binary(5)} & #{imm.to_binary(16)}"
end

def instruction_j(op, addr)
  "#{op} & #{addr.to_binary(26)}"
end

def wait_step(length)
  length.times { step {} }
end

