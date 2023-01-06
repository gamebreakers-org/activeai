class ActiveAI::Behavior::LLM::Conversation < ActiveAI::Behavior::LLM
  # i need alerts if this stuff gets caught in a loop! like pondering->noticing and never stopping or something

  def initialize(llm, state)
    super(llm)
    @state = state
    # TODO raise errors if not expected thingies available in the config
    @state['conversation'] ||= ""
  end

  def history
    @state['conversation']
  end

  def prompt
    [
      @state['instruction'],
      @state['examples'].map do |example|
        "Example Conversation:\n" + example['conversation']
        # TODO use the label key they provide in the yml file
      end,
      "Conversation:\n" + @state['conversation']
    ].join(LINE_SEPARATOR)
  end

  def add(speaker, message)
    comms = "#{speaker}: #{message.strip}"
    @state['conversation'] += comms + "\n"
  end

  def get_reply(prefix: nil)
    @state['conversation'] += prefix if prefix

    complete_result = complete(prompt, stop: "\n")
    completion = complete_result['choices'][0]['text']

    @state['conversation'] += completion + "\n"

    completion
  end
end
