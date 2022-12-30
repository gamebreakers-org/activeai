class ActiveAI::Controller
  # auto-loads a router from current file when inherited
  class_attribute :router

  def self.inherited(base)
    # routes_path = __FILE__.split('/')[0..-2].join('/') + "/routes.yml"
    routes_path = "/Users/jeriko/Developer/thinkspawn/app/models/plugins/open_ai/routes.yml"
    # TODO this is the wrong file, we need the actual inheritor somehow

    routes_config = YAML::load(File.read(routes_path))
    router = ActiveAI::Router.new(routes_config, controller: base)
  end

  attr_accessor :params

  def call(method_name, params)
    @params = params
    send(method_name)
  end
end
