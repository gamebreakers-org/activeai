class ActiveAI::Controller
  # auto-loads a router from current file when inherited
  class_attribute :router

  def self.inherited(base)
    # TODO I'm sure there's a proper way to do this but it works for now
    routes_path = Rails.root.join('config', 'routes', base.to_s.underscore.gsub('_controller', '.yml'))
    routes_config = YAML::load(File.read(routes_path))
    # convert routes_config params into JSON?
    router = ActiveAI::Router.new(routes_config, controller: base)
  end

  attr_accessor :params

  def call(method_name, params)
    @params = params
    send(method_name)
  end
end
