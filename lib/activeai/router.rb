class ActiveAI::Router
  INSTRUCTION = 'For a given Match request, choose where to send it via the "Route" field. If nothing matches, the "Route" field should be None.'
  UNMATCHED = { 'Match' => 'Create a NASA space program', 'Route' => 'None' }

  def initialize
    @routings = []
    @llm = ActiveAI::NeuralNetwork::GPT3.new(ActiveAI.config[:gpt3_token], model: 'text-curie-001', temperature: 0.2)
  end

  def add_controller_routing(routing)
    @routings << routing
  end

  def add_controller_routing_from_path(path)
    routing = YAML::load(File.read(path))
    add_controller_routing(routing)
  end

  def auto_load_routing(folder)
    paths = Dir[folder.join("**", "*.yml")]
    paths.each do |path|
      add_controller_routing_from_path(path)
    end
  end

  def behavior
    config = {
      'instruction' => INSTRUCTION,
      'examples' => [UNMATCHED] + @routings.map do |routing|
        routing['examples'].reject do |example|
          example['Route'] == 'None'
        end.map do |example|
          example.slice('Match', 'Route')
        end
      end.flatten
    }

    ActiveAI::Behavior::LLM::FollowStructuredExamples.new(@llm, config)
  end

  def find_controller(request)
    # should return constantized maybe?
    routing = behavior.call({ 'Request' => request }, extract: %W[Route])
    controller_name, action_name = routing['Route'].split('#')
    
    if controller_name == "None" || action_name.blank?
      return nil
    else
      return (controller_name + "_controller").classify.constantize
      # TODO need protection (somewhere) from using controllers that aren't allowed
      # maybe router has a whitelist? since we're taking user input
      # idk problem for later not now
    end
  end

  def call(request)
    if controller = find_controller(request)
      controller.new.call(request)
    else
      return nil
    end
  end
end
