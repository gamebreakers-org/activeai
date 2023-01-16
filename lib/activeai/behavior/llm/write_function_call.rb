class ActiveAI::Behavior::LLM::WriteFunctionCall < ActiveAI::Behavior::LLM
  def initialize(llm, state)
    super(llm)
    @state = state
    # TODO raise errors if not expected thingies available in the config
  end

  def base_prompt
    (@state[:examples].map do |example|
      "/* #{example[:description]} */\n#{example[:code]}"
    end + [""]).join("<|endoftext|>")
  end

  def call(comment)
    prompt = base_prompt
    prompt += "/* #{comment} */\n"

    complete_result = complete(prompt) # this still breaks sometimes by generating like 50 functions instead of stopping. think i fixed it? forgot an <|endoftext|> at the end

    # puts prompt
    # puts complete_result

    completion = complete_result['choices'][0]['text']
    completion = completion.strip.gsub("\n", "\\n") # fixes parsing errors (in JSON??)

    matcher = /(.*?)\((.*)\)/m # should be made ungreedy, but then i dont see when it over-completes because it fails silently
    matches = matcher.match(completion)

    if matches.nil?
      # binding.pry
      raise "Unmatched router response in #{self.class}"
    end

    return {
      text: completion.strip,
      path: matches[1],
      params: matches[2].presence && JSON.parse(matches[2])
    }
  end
end
