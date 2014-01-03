
class Assembly
  def initialize(insts)
    @insts = insts.split("\n").map { |l| "\t" + l }
  end

  def insert_labels(labels)
    labels
      .split("\n")
      .map { |label| split_label(label) }
      .sort { |a, b| a.last <=> b.last }
      .reverse_each { |labelmap|
        @insts.insert(labelmap.last, "# #{labelmap.first}")
      }
    @insts
  end

  def split_label(label)
    labelmap = label.split(' ')
    [label, labelmap.last.to_i]
  end
end

puts Assembly.new(File.read(ARGV[0])).insert_labels(File.read(ARGV[1])).insert(0, '.text').join("\n")
