def exclude_filename_match(path, *exclude_regexps)
  res = Dir[File.expand_path(path, File.dirname(__FILE__))].select { |f| !exclude_regexps.one? { |e| f.match(e) } }
end

class Integer
  def to_binary(length=2)
    "\"#{(2**length + self).to_s(2)[-length..-1]}\""
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
