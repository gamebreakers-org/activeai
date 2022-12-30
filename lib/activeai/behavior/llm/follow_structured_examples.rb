class ActiveAI::Behavior::LLM::FollowStructuredExamples < ActiveAI::Behavior::LLM
  # state is an instruction, and a list of examples with key/value pairs
  # would be nice to do casting, but not now i dont think..

  def initialize(llm, state)
    super(llm)
    @state = state
    # TODO raise errors if not expected thingies available in the config
  end

  def base_prompt
    [
      @state['instruction'],
      @state['examples'].map do |example|
        example.map do |key, value|
          "#{key}: #{value}"
        end.join("\n")
      end.join(SEPARATOR)
    ].join(SEPARATOR)
  end

  def call(input={}, extract: []) # TODO cool splat stuff?
    prompt = base_prompt + SEPARATOR

    prompt += input.map do |key, value|
      "#{key}: #{value}"
    end.join("\n")

    complete_result = complete(prompt)
    completion = complete_result['choices'][0]['text']

    return extract_keys(completion, extract)
  end
end
