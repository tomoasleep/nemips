require 'yaml'
require 'erb'
require 'forwardable'

class Hash
  def except_keys_in(*keys)
    hash_clone = self.clone
    keys.each { |k| hash_clone.delete k }
    hash_clone
  end
end

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
    parse_orders('result', @orders)
    @order_groups = @order_groups_each_stage.transpose[@stage_idx]
    @result_group = @order_groups.last
    puts to_vhdl
  end

  private
  def parse_orders(group_name, orders)
    settings = orders['settings']
    order_type = "#{settings['type']}_type"
    order_prefix = settings['prefix']

    _, order_state_maps = 
      orders
    .except_keys_in('settings')
    .reverse_each
    .reduce(
      [Array.new(@stages.size, 'nop'), {}]
    ) do |(last_s, os_maps), (order, v)|
      states = case v
               when Hash
                 parse_orders(order, v)
               when Array
                 @stages.zip(v).map { |stage, state| "#{stage}_#{state}" }
               when String
                 v
               else
                 last_s
               end

      order_name = (order == 'others') ? order : "#{order_prefix}_#{order}"
      [states, os_maps.merge(order_name => states)]
    end

    signals = @stages.map { |stage| "#{stage}_#{group_name}" }
    signal_types = @stages.map { |stage| "#{stage}_type" }

    @order_groups_each_stage ||= []
    @order_groups_each_stage << OrderGroup
      .new_each_stage(signals, signal_types, order_state_maps, order_type)

    signals
  end

  def to_vhdl
    DecoderPresenter.new(
      @order_groups, @result_group, @stages[@stage_idx], @dependencies).to_vhdl
  end
end

class DecoderPresenter
  TemplatePath = File.expand_path('../templates/decoder.vhd.erb', __FILE__)

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
    file_content = File.read(TemplatePath)
    templete = ERB.new(file_content, nil, '-')
    templete.result(binding)
  end
end

class OrderGroup
  def self.new_each_stage(signals, signal_types, order_state_maps, order_type)
    order_state_maps =
      order_state_maps
    .values
    .transpose.map { |v| Hash[order_state_maps.keys.zip(v)] }

    [signals, signal_types, order_state_maps].transpose.map do |args|
      new(*args, order_type)
    end
  end

  attr_reader :signal, :signal_type, :order_state_map, :order_type
  def initialize(signal, signal_type, order_state_map, order_type)
    @signal = signal
    @order_state_map = order_state_map
    @signal_type = signal_type
    @order_type = order_type
  end
end

class OrderGroupWrapper
  extend Forwardable

  def_delegators :@order_group,
    :signal, :signal_type, :order_type, :order_state_map

  def initialize(order_group)
    @order_group = order_group
  end

  def input_name
    order_type.gsub(/_type$/, '')
  end

  def group_by_select
    (tb = order_state_map.except_keys_in('others'))
      .keys
      .group_by { |k| tb[k] }
  end

  def others_value
    order_state_map['others']
  end
end

DecoderMaker.new(ARGV[0], ARGV[1]).run
