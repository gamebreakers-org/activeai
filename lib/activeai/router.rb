class ActiveAI::Router
  INSTRUCTION_ALL = 'For a given Match request, choose where to send it via the "Route" field. If nothing matches, the "Route" field should be None.'
  UNMATCHED_ALL = { 'Match' => 'Create a NASA space program', 'Route' => 'None' }
  INSTRUCTION_INSTANCE = 'For a given Match request, choose where to send it via the "Route" field. Also choose the params that fit best. If nothing matches, the "Route" field should be None.'

  # TODO could load a "session" or "context" for current user which handles router registration and stuff
  # keeps it flexi for thinkspawn while not breaking things on this layer

  class_attribute :routers
  self.routers = []

  def self.application_router # TODO use this
    new({
      'instruction' => INSTRUCTION_ALL,
      'examples' => routers.map do |router|
        router.config['examples'].select do |example|
          example['Route'] != 'None'
        end.map do |example|
          example.slice('Match', 'Route')
        end << UNMATCHED_ALL
      end.flatten
    })
  end

  def self.call_all(request)
    # this shouldn't be the thing, something just decides if it matches or not
    # we actually ask a master router where to go, and then ask the specific router what the params are
    # -- might hit the token limit though, so why not just do each one? less web requests? but infinite scale

    routers.each do |router|
      response = router.call(request)
      return response if response
    end
  end

  attr_accessor :config

  def initialize(config, controller: nil)
    self.class.routers ||= []

    @config = config
    @config['instruction'] ||= INSTRUCTION_INSTANCE

    llm = ActiveAI::NeuralNetwork::GPT3.new(ActiveAI.config[:gpt3_token], model: 'text-davinci-003', temperature: 0.2)
    @behavior = ActiveAI::Behavior::LLM::FollowStructuredExamples.new(llm, config)

    if controller
      self.class.routers << self
      @controller = controller.new
    end
  end

  def call(request)
    puts "CALLING ON ROUTER #{@controller} for #{request}"
    puts

    routing = @behavior.call({ 'Request' => request }, extract: %W[Route Params]) # TODO might not have params returned, will break?
    puts routing
    controller_name, method_name = routing['Route'].split('#')

    if [controller_name, method_name].any?(&:blank?)
      # unmatched
      return nil
    else
      params = JSON.parse(routing['Params']) # TODO cast as JSON earlier? e.g. in config of the behavior?
      puts "Calling #{method_name} with params: #{params}." # but only if matched

      if @controller.is_a?(ActiveAI::Controller)
        return @controller.call(method_name, params)
      else
        # it could be a dynamic user-generated script or something to call out to somehow
        # TODO later later
        return true
      end
    end
  end
end
