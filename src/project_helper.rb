
class VhdlConnector::Presenters::ConnectorPresenter

  def project_components(*args)
    @entity_list ||= Dir['src/**/*.vhd'] + Dir['lib/*.vhd']
    @entity_map ||=
      Hash[@entity_list.map { |path| [File.basename(path, '.vhd').to_sym, path] }]

    components(*parse_args(args))
  end

  def parse_args(args)
    args.map do |arg|
      case arg
      when Array
        parse_args(arg)
      when String, Symbol
        raise arg unless (str = @entity_map[arg.to_sym])
        str
      else
        arg
      end
    end.flatten
  end

  def project_components_mapping(opt = {})
    mapping(opt.merge({ as: { clk: 'clk' }.merge(opt[:as] || {})}))
  end

  def project_define_component_mappings(opt = {})
    define_component_mappings(
      opt.merge({ as: { clk: 'clk' }.merge(opt[:as] || {})})
    )
  end
end
