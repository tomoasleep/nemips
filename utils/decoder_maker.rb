require 'yaml'
require 'erb'

class DecoderMaker
  def initialize(yaml_path, stage_name)
    @yaml = YAML.load(File.read(yaml_path))
    @stages = @yaml['has_state'].map { |stage| "#{stage}_state" }
    @orders = @yaml['order']
    @dependencies = @yaml['dependencies']
    @stage_idx = @stages.find_index("#{stage_name}_state")

    unless @stage_idx
      raise "stage name'#{stage_name}_state' isnot exist in [#{@stages.join(', ')}]"
    end
  end

  def run
    parse_orders('signal_result', @orders)
    @order_groups = @group_orders.transpose[@stage_idx]
    @result_group = @order_groups.last
    puts to_vhdl
  end

  def parse_orders(group_name, orders)
    group_type = "#{orders['settings']['type']}_type"
    order_prefix = orders['settings']['prefix']

    _, parsed_orders =
      orders.tap { |o| o.delete('settings'); }
    .reverse_each
    .reduce(
      [Array.new(@stages.size, 'nop'), {}]
    ) do |(last_v, result), (k, v)|
      res = case v
            when Hash
              parse_orders(k, v)
            when Array
              @stages.zip(v).map { |stage, state| "#{stage}_#{state}" }
            when String
              v
            else
              last_v
            end

      order_name = (k == 'others') ? k : "#{order_prefix}_#{k}"
      [res, result.merge(order_name => res)]
    end
    signals = @stages.map { |stage| "#{stage}_#{group_name}" }
    types = @stages.map { |stage| "#{stage}_type" }

    @group_orders ||= []
    @group_orders << OrderGroup.new_groups(
      signals, parsed_orders, types, group_type)
    signals
  end

  def to_vhdl
    DecoderPresenter.new(
      @order_groups, @result_group, @stages[@stage_idx], @dependencies).to_vhdl
  end

  class OrderGroup
    # Public: Create OrderGroup Array of each stages
    # signals - num of stages size signal Names each OrderGroup assign
    # multi_order_table - Hash of (key Name, stages size value)
    # types - signal types
    # group_types - stages size of key type
    def self.new_groups(signals, multi_order_table, types, group_type)
      order_tables = multi_order_table.values.transpose.map do |v|
        Hash[multi_order_table.keys.zip(v)]
      end
      [signals, order_tables, types].transpose.map do |args|
        new(*args, group_type)
      end
    end

    attr_reader :signal, :order_table, :signal_type, :group_type
    def initialize(signal, order_table, signal_type, group_type)
      @signal = signal
      @order_table = order_table
      @signal_type = signal_type
      @group_type = group_type
    end
  end

  class DecoderPresenter
    TempletePath = File.expand_path('../templetes/decoder.vhd.erb', __FILE__)

    attr_reader :dependencies
    def initialize(order_groups, result_group, stage, dependencies)
      @order_groups = order_groups
      @result_group = result_group
      @stage = stage
      @dependencies = dependencies
    end

    def groups
      @order_groups.map { |g| OrderGroupWrapper.new(g) }
    end

    def groups_expect_result
      @order_groups.map do |g|
        OrderGroupWrapper.new(g) unless g == @result_group 
      end.compact
    end

    def result_group
      OrderGroupWrapper.new(@result_group)
    end

    def decoder_name
      "#{@stage}_decoder"
    end

    def decoder_name
      "#{@stage}_decoder"
    end

    def to_vhdl
      file_content = File.read(TempletePath)
      templete = ERB.new(file_content, nil, '-')
      templete.result(binding)
    end
  end

  class OrderGroupWrapper
    def initialize(order_group)
      @order_group = order_group
    end

    def signal; @order_group.signal; end
    def signal_type; @order_group.signal_type; end
    def case_type; @order_group.group_type; end

    def group_by_select
      (tb = order_table_except_others).keys.group_by { |k| tb[k] }
    end

    def order_table_except_others
      (tb = @order_group.order_table.merge({})).delete('others')
      tb
    end

    def others_value
      @order_group.order_table['others']
    end
  end
end

DecoderMaker.new(ARGV[0], ARGV[1]).run
