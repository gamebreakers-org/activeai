class ActiveAI::Controller

  class_attribute :routing_behavior

  def self.auto_load_routing
    routes_path = Rails.root.join('config', 'routes', self.to_s.underscore.gsub('_controller', '.yml'))
    routes_config = YAML::load(File.read(routes_path))
    self.load_routing(routes_config)
  end

  def self.load_routing(routes_config)
    @llm = ActiveAI::NeuralNetwork::GPT3.new(ActiveAI.config[:gpt3_token], model: 'text-curie-001', temperature: 0.2)
    self.routing_behavior = ActiveAI::Behavior::LLM::FollowStructuredExamples.new(@llm, routes_config)
  end

  attr_accessor :params

  def prepare_action(request)
    routing = self.class.routing_behavior.call({ 'Request' => request }, extract: %W[Route Params])
    controller_name, action_name = routing['Route'].split('#')
    # TODO verify it's the right controller and the action name exists and it's not a reserved / internal thing
    return {
      action: action_name,
      params: JSON.parse(routing['Params']) # TODO cast as JSON earlier? e.g. in config of the behavior? 
    }
  end

  def call(request)
    mapped_request = prepare_action(request)
    
    if mapped_request
      return run_action(mapped_request[:action], mapped_request[:params])
    else
      return nil
    end
  end

  def run_action(action_name, params)
    @params = params
    response = send(action_name)
    # handle response somehow, or do we just dump JSON back?
  end

  # surely this is where the magic prep loading and unloading happens?
  # i.e. the params deal with this
end
