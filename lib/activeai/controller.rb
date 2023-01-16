class ActiveAI::Controller

  class_attribute :routing_behavior

  def self.auto_load_routing
    routes_path = Rails.root.join('config', 'routes', self.to_s.underscore.gsub('_controller', '.yml'))
    routes_config = YAML::load(File.read(routes_path))
    self.load_routing(routes_config)
  end

  def self.load_routing(routes_config)
    @llm = ActiveAI::NeuralNetwork::GPT3.new(ActiveAI.config[:gpt3_token], model: 'code-cushman-001', temperature: 0)

    examples = ActiveAI.route_examples_to_function_call_examples(routes_config['examples'])
    self.routing_behavior = ActiveAI::Behavior::LLM::WriteFunctionCall.new(@llm, { examples: examples })
  end

  attr_accessor :params

  def initialize(provider)
    @provider = provider
  end

  def prepare_action(request)
    # samples to parse:
    #   plugins.slack.send_message({ \"channel\": \"#general\", \"text\": \"Hi\" })
    #   unmatched()

    function = self.class.routing_behavior.call(request)
    *controller_path, action_name = function[:path].split(".")
    controller_name = controller_path.join("/").presence

    # TODO verify it's the right controller and the action name exists and it's not a reserved / internal thing

    if controller_name.present?
      return {
        action: action_name,
        params: function[:params]
      }
    else
      return nil
    end
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
