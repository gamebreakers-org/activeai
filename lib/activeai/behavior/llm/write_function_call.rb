class ActiveAI::Behavior::LLM::WriteFunctionCall < ActiveAI::Behavior::LLM
  def initialize(llm, state)
    super(llm)
    @state = state
    # TODO raise errors if not expected thingies available in the config
  end

  def base_prompt
    @state[:examples].map do |example|
      [
        "// #{example[:description]}",
        example[:code]
      ].join("\n")
    end.join("\n\n") + "\n\n"
  end

  def call(comment)
    prompt = base_prompt + "\n\n"
    prompt += "//#{comment}\n"
    complete_result = complete(prompt, stop: "\n")

    # TODO stop \n works for the router but not for other stuff, later

    completion = complete_result['choices'][0]['text']

    matcher = /(.*)\((.*)\)/
    matches = matcher.match(completion)

    return {
      text: completion.strip,
      path: matches[1],
      params: matches[2].presence && JSON.parse(matches[2])
    }
  end
end
