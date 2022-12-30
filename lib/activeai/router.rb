class ActiveAI::Router
  # TODO could load a "session" or "context" for current user which handles router registration and stuff
  # keeps it flexi for thinkspawn while not breaking things on this layer

  class_attribute :routers
  self.routers = []

  def self.call_all(request)
    routers.detect do |router|
      response = router.call(request)
    end
  end

  def initialize(config, controller:)
    self.class.routers ||= [] << self # does this work?

    @config = config
    llm = ActiveAI::NeuralNetwork::GPT3.new(ActiveAI.config[:gpt3_token], model: 'text-curie-001')
    @behavior = ActiveAI::Behavior::LLM::FollowStructuredExamples.new(llm, config)
    @controller = controller.new
  end

  def call(request)
    routing = @behavior.call({ 'Request' => request }, extract: %W[To Params]) # TODO might not have params returned, will break?

    controller_name, method_name = routing['To'].split('#')

    if [controller_name, method_name].any?(&:blank?)
      # unmatched
      nil
    else
      params = JSON.parse(routing['Params']) # TODO cast as JSON earlier? e.g. in config of the behavior?
      puts "Calling #{method_name} with params: #{params}." # but only if matched

      if controller.is_a?(ActiveAI::Controller)
        return @controller.call(method_name, params)
      else
        # it could be a dynamic user-generated script or something to call out to somehow
        # TODO later later
        return true
      end
    end
  end
end
